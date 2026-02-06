/**
 * VENN SOCIAL VENDOR AUTOMATION BACKEND
 * Google Apps Script for vendor follow-up workflow automation
 * 
 * This script provides API endpoints for the n8n vendor follow-up workflow
 * and manages vendor data in Google Sheets with comprehensive logging
 */

// CONFIGURATION
const CONFIG = {
  VENDOR_SHEET_ID: 'YOUR_VENDOR_SHEET_ID', // Replace with actual Google Sheets ID
  AUDIT_SHEET_ID: 'YOUR_AUDIT_SHEET_ID',   // Replace with audit log sheet ID
  TEMPLATE_FOLDER_ID: 'YOUR_TEMPLATE_FOLDER_ID', // Google Drive folder with email templates
  
  // Email templates mapping
  EMAIL_TEMPLATES: {
    'followup_24h': '24_Hour_Followup_Template',
    'followup_48h': '48_Hour_Followup_Template', 
    'followup_72h': '72_Hour_Final_Followup_Template'
  },
  
  // Sheet column mappings
  VENDOR_COLUMNS: {
    VENDOR_ID: 'A',
    VENDOR_NAME: 'B',
    VENDOR_EMAIL: 'C',
    VENDOR_PHONE: 'D',
    EVENT_NAME: 'E',
    ORIGINAL_INQUIRY_DATE: 'F',
    LAST_CONTACT_DATE: 'G',
    FOLLOW_UP_COUNT: 'H',
    STATUS: 'I',
    RESPONSE_RECEIVED: 'J',
    NOTES: 'K',
    NEXT_FOLLOW_UP_DUE: 'L'
  },
  
  FOLLOW_UP_INTERVALS: {
    FIRST: 24,    // 24 hours
    SECOND: 48,   // 48 hours  
    FINAL: 72     // 72 hours
  }
};

/**
 * Main entry point for n8n webhook calls
 * Handles all automation actions based on the 'action' parameter
 */
function doPost(e) {
  try {
    const data = JSON.parse(e.postData.contents);
    const action = data.action;
    
    logAuditEvent('API_CALL', {
      action: action,
      timestamp: new Date().toISOString(),
      source: 'n8n_workflow',
      data: data
    });
    
    switch (action) {
      case 'get_pending_followups':
        return ContentService.createTextOutput(
          JSON.stringify(getPendingFollowups(data.run_id))
        ).setMimeType(ContentService.MimeType.JSON);
        
      case 'get_email_template':
        return ContentService.createTextOutput(
          JSON.stringify(getEmailTemplate(data))
        ).setMimeType(ContentService.MimeType.JSON);
        
      case 'log_followup_sent':
        return ContentService.createTextOutput(
          JSON.stringify(logFollowupSent(data))
        ).setMimeType(ContentService.MimeType.JSON);
        
      case 'log_workflow_completion':
        return ContentService.createTextOutput(
          JSON.stringify(logWorkflowCompletion(data))
        ).setMimeType(ContentService.MimeType.JSON);
        
      case 'process_vendor_response':
        return ContentService.createTextOutput(
          JSON.stringify(processVendorResponse(data))
        ).setMimeType(ContentService.MimeType.JSON);
        
      default:
        throw new Error(`Unknown action: ${action}`);
    }
    
  } catch (error) {
    console.error('API Error:', error);
    logAuditEvent('API_ERROR', {
      error: error.toString(),
      timestamp: new Date().toISOString(),
      stack: error.stack
    });
    
    return ContentService.createTextOutput(
      JSON.stringify({ error: error.toString() })
    ).setMimeType(ContentService.MimeType.JSON);
  }
}

/**
 * Get all vendors that need follow-up based on timing rules
 */
function getPendingFollowups(runId) {
  const sheet = SpreadsheetApp.openById(CONFIG.VENDOR_SHEET_ID).getActiveSheet();
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const rows = data.slice(1);
  
  const pendingVendors = [];
  const now = new Date();
  
  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];
    const vendor = {};
    
    // Map row data to vendor object
    headers.forEach((header, index) => {
      vendor[header.toLowerCase().replace(/ /g, '_')] = row[index];
    });
    
    // Skip if no email or already responded
    if (!vendor.vendor_email || vendor.response_received === 'YES') {
      continue;
    }
    
    const lastContactDate = new Date(vendor.last_contact_date);
    const hoursSinceContact = (now - lastContactDate) / (1000 * 60 * 60);
    const followUpCount = parseInt(vendor.follow_up_count) || 0;
    
    // Determine if follow-up is needed
    let needsFollowup = false;
    
    if (followUpCount === 0 && hoursSinceContact >= CONFIG.FOLLOW_UP_INTERVALS.FIRST) {
      needsFollowup = true;
    } else if (followUpCount === 1 && hoursSinceContact >= CONFIG.FOLLOW_UP_INTERVALS.SECOND) {
      needsFollowup = true;
    } else if (followUpCount === 2 && hoursSinceContact >= CONFIG.FOLLOW_UP_INTERVALS.FINAL) {
      needsFollowup = true;
    }
    
    if (needsFollowup && followUpCount < 3) {
      vendor.vendor_id = vendor.vendor_id || generateVendorId();
      vendor.row_index = i + 2; // +2 for header and 0-index adjustment
      pendingVendors.push(vendor);
    }
  }
  
  logAuditEvent('PENDING_FOLLOWUPS_CHECK', {
    run_id: runId,
    vendors_found: pendingVendors.length,
    vendor_names: pendingVendors.map(v => v.vendor_name),
    timestamp: new Date().toISOString()
  });
  
  return {
    pending_vendors: pendingVendors,
    total_count: pendingVendors.length,
    run_id: runId
  };
}

/**
 * Generate personalized email content using templates
 */
function getEmailTemplate(data) {
  const templateName = data.template_name;
  const vendorName = data.vendor_name;
  const eventName = data.event_name;
  
  try {
    // Get template from Google Drive
    const templateDoc = DriveApp.getFolderById(CONFIG.TEMPLATE_FOLDER_ID)
      .getFilesByName(CONFIG.EMAIL_TEMPLATES[templateName])
      .next();
    
    let templateContent = DocumentApp.openById(templateDoc.getId()).getBody().getText();
    
    // Replace placeholders with actual data
    templateContent = templateContent
      .replace(/{{VENDOR_NAME}}/g, vendorName)
      .replace(/{{EVENT_NAME}}/g, eventName)
      .replace(/{{DATE}}/g, new Date().toLocaleDateString())
      .replace(/{{SENDER_NAME}}/g, 'Venn Social Team')
      .replace(/{{COMPANY_NAME}}/g, 'Venn Social');
    
    // Add professional signature
    const signature = `
    <br><br>Best regards,<br>
    <strong>Venn Social Events Team</strong><br>
    Creating exclusive dining experiences in San Francisco<br>
    <a href="mailto:hello@vennsocial.com">hello@vennsocial.com</a>
    `;
    
    return {
      email_content: templateContent + signature,
      template_used: templateName,
      personalized_for: vendorName
    };
    
  } catch (error) {
    console.error('Template Error:', error);
    
    // Fallback template if Google Drive template fails
    const fallbackTemplates = {
      'followup_24h': `Hi {{VENDOR_NAME}},\n\nI wanted to follow up on our inquiry about {{EVENT_NAME}}. We're excited about the possibility of working together.\n\nCould you please let us know your availability and any initial thoughts?\n\nLooking forward to hearing from you!`,
      'followup_48h': `Hi {{VENDOR_NAME}},\n\nI'm following up on our inquiry about {{EVENT_NAME}}. We understand you're likely busy, but wanted to check if you had a chance to review our request.\n\nWe're very interested in your venue and would appreciate any feedback you might have.\n\nThank you for your time!`,
      'followup_72h': `Hi {{VENDOR_NAME}},\n\nThis is our final follow-up regarding {{EVENT_NAME}}. We completely understand if this opportunity isn't the right fit.\n\nIf you're interested, please let us know by end of week. Otherwise, we'll assume you're not available for this event.\n\nThank you for considering us!`
    };
    
    let content = fallbackTemplates[templateName] || fallbackTemplates['followup_24h'];
    content = content
      .replace(/{{VENDOR_NAME}}/g, vendorName)
      .replace(/{{EVENT_NAME}}/g, eventName);
    
    return {
      email_content: content,
      template_used: templateName,
      fallback_used: true
    };
  }
}

/**
 * Log that a follow-up email was sent and update vendor record
 */
function logFollowupSent(data) {
  const sheet = SpreadsheetApp.openById(CONFIG.VENDOR_SHEET_ID).getActiveSheet();
  const vendorId = data.vendor_id;
  const followUpType = data.follow_up_type;
  
  // Find vendor row
  const dataRange = sheet.getDataRange();
  const values = dataRange.getValues();
  
  for (let i = 1; i < values.length; i++) {
    if (values[i][0] === vendorId) { // Assuming vendor_id is in column A
      // Update follow-up count
      const currentCount = parseInt(values[i][7]) || 0; // Column H
      sheet.getRange(i + 1, 8).setValue(currentCount + 1);
      
      // Update last contact date
      sheet.getRange(i + 1, 7).setValue(new Date()); // Column G
      
      // Update status
      sheet.getRange(i + 1, 9).setValue(`${followUpType}_sent`); // Column I
      
      // Calculate next follow-up date
      const nextFollowUpDate = calculateNextFollowUpDate(currentCount + 1);
      sheet.getRange(i + 1, 12).setValue(nextFollowUpDate); // Column L
      
      break;
    }
  }
  
  // Log the action
  logAuditEvent('FOLLOWUP_SENT', {
    vendor_id: vendorId,
    follow_up_type: followUpType,
    email_sent_time: data.email_sent_time,
    run_id: data.run_id
  });
  
  return {
    success: true,
    vendor_id: vendorId,
    follow_up_logged: followUpType
  };
}

/**
 * Process vendor response (when they reply to our emails)
 */
function processVendorResponse(data) {
  const sheet = SpreadsheetApp.openById(CONFIG.VENDOR_SHEET_ID).getActiveSheet();
  const vendorEmail = data.vendor_email;
  const responseType = data.response_type; // 'positive', 'negative', 'needs_info'
  const responseContent = data.response_content;
  
  // Find vendor by email
  const dataRange = sheet.getDataRange();
  const values = dataRange.getValues();
  
  for (let i = 1; i < values.length; i++) {
    if (values[i][2] === vendorEmail) { // Column C = vendor_email
      // Mark response received
      sheet.getRange(i + 1, 10).setValue('YES'); // Column J
      
      // Update status based on response type
      let status = 'response_received';
      switch (responseType) {
        case 'positive':
          status = 'interested';
          break;
        case 'negative':
          status = 'declined';
          break;
        case 'needs_info':
          status = 'requires_more_info';
          break;
      }
      sheet.getRange(i + 1, 9).setValue(status); // Column I
      
      // Add response to notes
      const currentNotes = values[i][10] || ''; // Column K
      const newNotes = currentNotes + `\n[${new Date().toLocaleDateString()}] Response: ${responseContent}`;
      sheet.getRange(i + 1, 11).setValue(newNotes); // Column K
      
      break;
    }
  }
  
  // Log the response
  logAuditEvent('VENDOR_RESPONSE_PROCESSED', {
    vendor_email: vendorEmail,
    response_type: responseType,
    processed_time: new Date().toISOString()
  });
  
  return {
    success: true,
    vendor_email: vendorEmail,
    response_processed: responseType
  };
}

/**
 * Log workflow completion for analytics and monitoring
 */
function logWorkflowCompletion(data) {
  logAuditEvent('WORKFLOW_COMPLETION', {
    run_id: data.run_id,
    vendors_processed: data.vendors_processed,
    completion_time: data.completion_time,
    status: data.status
  });
  
  return {
    success: true,
    logged: true
  };
}

/**
 * Calculate next follow-up date based on current count
 */
function calculateNextFollowUpDate(currentCount) {
  const now = new Date();
  let hoursToAdd;
  
  switch (currentCount) {
    case 1:
      hoursToAdd = CONFIG.FOLLOW_UP_INTERVALS.SECOND - CONFIG.FOLLOW_UP_INTERVALS.FIRST;
      break;
    case 2:
      hoursToAdd = CONFIG.FOLLOW_UP_INTERVALS.FINAL - CONFIG.FOLLOW_UP_INTERVALS.SECOND;
      break;
    default:
      return null; // No more follow-ups
  }
  
  return new Date(now.getTime() + hoursToAdd * 60 * 60 * 1000);
}

/**
 * Generate unique vendor ID
 */
function generateVendorId() {
  return 'VN' + new Date().getTime().toString().slice(-8) + Math.random().toString(36).substr(2, 4).toUpperCase();
}

/**
 * Centralized audit logging
 */
function logAuditEvent(eventType, eventData) {
  try {
    const auditSheet = SpreadsheetApp.openById(CONFIG.AUDIT_SHEET_ID).getActiveSheet();
    
    const logEntry = [
      new Date(),
      eventType,
      JSON.stringify(eventData),
      'vendor_automation',
      eventData.run_id || 'manual'
    ];
    
    auditSheet.appendRow(logEntry);
    
  } catch (error) {
    console.error('Audit logging failed:', error);
  }
}

/**
 * Setup function - run once to create necessary sheets and structure
 */
function setupVendorAutomation() {
  // Create vendor tracking sheet headers
  const vendorSheet = SpreadsheetApp.openById(CONFIG.VENDOR_SHEET_ID).getActiveSheet();
  const vendorHeaders = [
    'Vendor ID', 'Vendor Name', 'Vendor Email', 'Vendor Phone', 'Event Name',
    'Original Inquiry Date', 'Last Contact Date', 'Follow Up Count', 'Status',
    'Response Received', 'Notes', 'Next Follow Up Due'
  ];
  vendorSheet.getRange(1, 1, 1, vendorHeaders.length).setValues([vendorHeaders]);
  
  // Create audit log sheet headers
  const auditSheet = SpreadsheetApp.openById(CONFIG.AUDIT_SHEET_ID).getActiveSheet();
  const auditHeaders = [
    'Timestamp', 'Event Type', 'Event Data', 'Source', 'Run ID'
  ];
  auditSheet.getRange(1, 1, 1, auditHeaders.length).setValues([auditHeaders]);
  
  console.log('Vendor automation setup complete!');
}

/**
 * Test function for development
 */
function testAutomation() {
  const testData = {
    action: 'get_pending_followups',
    run_id: 'test-run-' + new Date().getTime()
  };
  
  const result = getPendingFollowups(testData.run_id);
  console.log('Test result:', result);
  
  return result;
}
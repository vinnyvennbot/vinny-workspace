#!/usr/bin/env node

/**
 * Simple Gmail polling webhook for vendor responses
 * Checks Gmail every 2 minutes for new vendor emails
 */

const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const POLL_INTERVAL = 120000; // 2 minutes
const LAST_CHECK_FILE = path.join(__dirname, '../.last-email-check');

function runGogCommand(command) {
  return new Promise((resolve, reject) => {
    exec(`gog ${command}`, (error, stdout, stderr) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(stdout);
    });
  });
}

function getLastCheckTime() {
  try {
    if (fs.existsSync(LAST_CHECK_FILE)) {
      return fs.readFileSync(LAST_CHECK_FILE, 'utf8').trim();
    }
  } catch (error) {
    console.log('No previous check time found');
  }
  return '1d'; // Default to 1 day ago
}

function saveLastCheckTime() {
  const now = new Date().toISOString();
  fs.writeFileSync(LAST_CHECK_FILE, now);
}

async function checkForNewVendorEmails() {
  try {
    const lastCheck = getLastCheckTime();
    console.log(`Checking for emails newer than: ${lastCheck}`);
    
    // Search for vendor emails (not from vinny@vennapp.co or zed.truong@vennapp.co)
    const searchQuery = `newer_than:${lastCheck} -from:vinny@vennapp.co -from:zed.truong@vennapp.co`;
    const results = await runGogCommand(`gmail search '${searchQuery}' --max 10 --json`);
    
    const emails = JSON.parse(results);
    
    if (emails && emails.length > 0) {
      console.log(`Found ${emails.length} new emails!`);
      
      // Filter for potential vendor responses
      const vendorEmails = emails.filter(email => {
        const subject = email.subject.toLowerCase();
        const from = email.from.toLowerCase();
        
        return (
          subject.includes('mechanical bull') ||
          subject.includes('private dining') ||
          subject.includes('event') ||
          subject.includes('quote') ||
          subject.includes('rental') ||
          from.includes('events') ||
          from.includes('catering') ||
          from.includes('rental')
        );
      });
      
      if (vendorEmails.length > 0) {
        console.log(`🎉 Found ${vendorEmails.length} potential vendor responses!`);
        
        // Send webhook to OpenClaw
        const webhookData = {
          type: 'vendor_email_alert',
          count: vendorEmails.length,
          emails: vendorEmails.map(email => ({
            id: email.id,
            from: email.from,
            subject: email.subject,
            date: email.date
          }))
        };
        
        // Trigger OpenClaw notification (you can customize this)
        console.log('Vendor emails detected:', JSON.stringify(webhookData, null, 2));
        
        return vendorEmails;
      }
    }
    
    saveLastCheckTime();
    console.log('No new vendor emails found');
    return [];
    
  } catch (error) {
    console.error('Error checking emails:', error);
    return [];
  }
}

// Run immediately
checkForNewVendorEmails().then((emails) => {
  if (emails.length > 0) {
    process.exit(0);
  } else {
    console.log('Email monitoring script completed - no new vendor emails');
    process.exit(0);
  }
});
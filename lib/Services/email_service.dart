import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // Send OTP via email using Gmail SMTP
  static Future<bool> sendOtpEmail({
    required String email,
    required String otp,
    required String name,
  }) async {
    try {
      // Gmail credentials
      final String username = 'hafizmuhammadrizwan359@gmail.com';
      final String password = 'ndxsbknoxbbrztbv'; // App password

      // Configure mail server
      final smtpServer = gmail(username, password);

      // Create email message
      final message = Message()
        ..from = Address(username, 'Marriage Bureau App')
        ..recipients.add(email)
        ..subject = 'Email Verification OTP Code'
        ..html = '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 5px;">
            <h2 style="color: #e91e63; text-align: center;">Marriage Bureau</h2>
            <h3 style="text-align: center;">Email Verification</h3>
            <p>Hello ${name},</p>
            <p>Thank you for registering with Marriage Bureau. To verify your email address, please use the following One-Time Password (OTP):</p>
            <div style="text-align: center; margin: 30px 0;">
              <div style="display: inline-block; padding: 15px 30px; background-color: #f5f5f5; border-radius: 5px; font-size: 24px; font-weight: bold; letter-spacing: 5px;">
                ${otp}
              </div>
            </div>
            <p>This OTP will expire in 10 minutes.</p>
            <p>If you did not request this verification, please ignore this email.</p>
            <p style="margin-top: 30px; font-size: 12px; color: #777; text-align: center;">
              This is an automated message, please do not reply.
            </p>
          </div>
        ''';

      // Send the email
      final sendReport = await send(message, smtpServer);
      print('Email sent: ${sendReport.toString()}');
      return true;
    } catch (e) {
      print('Error sending OTP email: $e');
      return false;
    }
  }

  // Alternative implementation using a mock function for testing
  static Future<bool> sendOtpEmailMock({
    required String email,
    required String otp,
  }) async {
    // This is a mock function that always returns success
    // In a real app, replace this with actual email sending logic
    print('Mock email sent to $email with OTP: $otp');

    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    return true;
  }
}

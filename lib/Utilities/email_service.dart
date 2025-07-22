import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static Future<bool> sendOtpEmail({
    required String recipientEmail,
    required String otp,
  }) async {
    // Email credentials
    final String username = 'hafizmuhammadrizwan359@gmail.com';
    final String password = 'ndxsbknoxbbrztbv'; // You'll need to generate an app password

    // Configure SMTP server
    final smtpServer = gmail(username, password);

    // Create the email message
    final message = Message()
      ..from = Address(username, 'Marriage Bureau App')
      ..recipients.add(recipientEmail)
      ..subject = 'Email Verification OTP'
      ..html = '''
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e6e6e6; border-radius: 5px;">
          <h2 style="color: #e91e63; text-align: center;">Email Verification</h2>
          <p>Dear User,</p>
          <p>Thank you for registering with Marriage Bureau App. Please use the following OTP to verify your email address:</p>
          <div style="text-align: center; margin: 30px 0;">
            <span style="font-size: 24px; font-weight: bold; background-color: #f5f5f5; padding: 10px 20px; border-radius: 5px; letter-spacing: 5px;">$otp</span>
          </div>
          <p>This OTP is valid for 10 minutes. If you didn't request this verification, please ignore this email.</p>
          <p>Regards,<br>Marriage Bureau App Team</p>
        </div>
      ''';

    try {
      // Send the email
      final sendReport = await send(message, smtpServer);
      print('Message sent: ${sendReport.toString()}');
      return true;
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }
}

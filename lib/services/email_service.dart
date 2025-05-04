import 'package:http/http.dart' as http;

Future<void> sendEmail({
  required String email,
  required String brandName,
  required bool isAccepted,
  String? rejectionReason,
}) async {
  final status = isAccepted ? "Accepted" : "Rejected";

  final message =
      isAccepted
          ? "Congratulations! Your brand <b>$brandName</b> has been accepted on our platform."
          : """
        Sorry! Your brand <b>$brandName</b> has been rejected.
        ${rejectionReason != null && rejectionReason.isNotEmpty ? "<br><b>Reason:</b> $rejectionReason" : ""}
        <br>Please contact support for details.
      """;

  var request = http.MultipartRequest(
    'POST',
    Uri.parse(
      'https://www.appelevates.com/beingmuslim/index.php/Services/send_emailMawaqif',
    ),
  );

  request.fields.addAll({
    'email': email,
    'subject': 'Brand Approval Status',
    'html_content': '''
      <html>
      <body>
        <h2>Brand Verification Update</h2>
        <p>Hello,</p>
        <p>$message</p>
        <br>
        <p>Thank you,<br><b>Mawqif Team</b></p>
      </body>
      </html>
    ''',
  });

  try {
    var response = await request.send();
    if (response.statusCode == 200) {
      print("Email sent successfully to $email");
    } else {
      print("Failed to send email: ${response.reasonPhrase}");
    }
  } catch (e) {
    print("Error sending email: $e");
  }
}

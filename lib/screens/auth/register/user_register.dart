import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/user_signup_controller.dart';

class UserSignUpScreen extends StatefulWidget {
  const UserSignUpScreen({super.key});

  @override
  State<UserSignUpScreen> createState() => _UserSignUpScreenState();
}

class _UserSignUpScreenState extends State<UserSignUpScreen> {
  final _controller = UserSignUpController();
  bool _obscurePassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (!_agreeToTerms) {
      Get.snackbar(
        "Terms Required",
        "Please agree to the terms.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.brown.shade100,
      );
      return;
    }

    _controller.signUp(
      onSuccess: () {
        Get.snackbar(
          "Success",
          "Account created successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.brown.shade200,
          colorText: Colors.black,
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          Get.toNamed(AppRoutes.userDashboard);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 33),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  "Create Account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  "Fill your information below to register.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              const SizedBox(height: 32),

              _buildLabel("Name"),
              _buildInputField("John Doe", _controller.nameController),

              const SizedBox(height: 18),
              _buildLabel("Email"),
              _buildInputField(
                "example@gmail.com",
                _controller.emailController,
              ),

              const SizedBox(height: 18),
              _buildLabel("Password"),
              _buildPasswordField(),

              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged:
                        (val) => setState(() => _agreeToTerms = val ?? false),
                    activeColor: Colors.brown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Agree with "),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    "Terms & Conditions",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Text(
                                      "By using the Mawqif mobile application, you agree to the following terms:\n\n"
                                      "1. Eligibility\n"
                                      "You must be at least 16 years old to use the Mawqif app. By creating an account, you confirm that you meet this requirement.\n\n"
                                      "2. Account Responsibility\n"
                                      "You are solely responsible for the accuracy of the information you provide and any activity conducted through your account.\n"
                                      "Do not share your login credentials or use another person’s account.\n\n"
                                      "3. Third-Party Transactions\n"
                                      "Mawqif serves as a platform to connect users with approved brands. We are not responsible for third-party product quality, order fulfillment, shipment, delivery, or payment issues. All transactions are made directly between the user and the brand.\n\n"
                                      "4. Privacy\n"
                                      "We respect your privacy. Your personal data is collected and used only to enhance your experience, provide customer support, and improve app performance. We do not sell your information.\n\n"
                                      "5. Misuse & Suspension\n"
                                      "Any misuse of the app — including fraudulent activity, brand impersonation, or abuse of services — may result in temporary or permanent account suspension without prior notice.\n\n"
                                      "Thank you for using Mawqif.\n",
                                    ),
                                  ),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 4.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Disagree
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.brown,
                                                elevation: 3,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _agreeToTerms = true;
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                "Agree",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          // Agree
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.brown,
                                                elevation: 3,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _agreeToTerms = false;
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                "Disagree",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            "Terms & Conditions",
                            style: TextStyle(
                              color: Colors.brown.shade600,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.login),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        const TextSpan(text: "Already have an account? "),
                        TextSpan(
                          text: "Sign In",
                          style: TextStyle(
                            color: Colors.brown.shade600,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.w600));

  Widget _buildInputField(String hint, TextEditingController controller) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.brown.shade600, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: _controller.passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          hintText: '••••••••••',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed:
                () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.brown.shade600, width: 1.5),
          ),
        ),
      ),
    );
  }
}

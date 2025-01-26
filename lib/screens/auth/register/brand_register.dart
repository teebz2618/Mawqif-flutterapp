import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/brand_signup_controller.dart';

class BrandSignUpScreen extends StatefulWidget {
  const BrandSignUpScreen({super.key});

  @override
  State<BrandSignUpScreen> createState() => _BrandSignUpScreenState();
}

class _BrandSignUpScreenState extends State<BrandSignUpScreen> {
  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Terms & Conditions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const SingleChildScrollView(
                  child: Text(
                    "By using the Mawqif platform as a brand, you agree to:\n\n"
                    "1. Providing authentic and accurate brand details.\n"
                    "2. Handling all customer orders, shipping, and returns responsibly.\n"
                    "3. Abiding by Mawqif's return, refund, and cancellation guidelines.\n"
                    "4. Ensuring product quality and timely delivery.\n"
                    "5. Refraining from misuse, fraud, or impersonation.\n"
                    "6. Allowing Mawqif to review, approve, or suspend your listing at any time.\n"
                    "\nYour information will be used only to facilitate brand listing and customer interactions. We do not sell your data.",
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _agreeToTerms = true);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Agree",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Disagree",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  final _controller = BrandSignUpController();
  final _formKey = GlobalKey<FormState>();
  bool _agreeToTerms = false;
  XFile? _logo;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _logo = pickedFile);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    setState(() {
      _autoValidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      Get.snackbar(
        "Terms Required",
        "Please agree to Terms & Policies.",
        backgroundColor: Colors.brown.shade100,
      );
      return;
    }

    if (_logo == null) {
      Get.snackbar(
        "Logo Required",
        "Please upload your brand logo.",
        backgroundColor: Colors.orange.shade100,
      );
      return;
    }

    _controller.signUpWithEmail(
      onSuccess: () {
        Get.dialog(
          AlertDialog(
            title: const Text("Application Submitted"),
            content: const Text(
              "Your application is under review. You’ll be notified upon approval.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.offAllNamed('/login');
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      },
      onError: (message) {
        Get.snackbar(
          "Sign Up Failed",
          message,
          backgroundColor: Colors.red.shade100,
        );
      },
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    bool isPassword = false,
    int maxLines = 1,
    String? hint,
    int? maxWords,
    String? Function(String?)? validator,
  }) {
    bool _obscure = true;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                children:
                    isRequired
                        ? [
                          const TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ]
                        : [],
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: controller,
              obscureText: isPassword ? _obscure : false,
              maxLines: maxLines,
              autovalidateMode: _autoValidateMode,
              decoration: InputDecoration(
                hintText: hint ?? label,
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                suffixIcon:
                    isPassword
                        ? IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed:
                              () => setState(() {
                                _obscure = !_obscure;
                              }),
                        )
                        : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.brown.shade600),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.red.shade700),
                ),
              ),
              validator:
                  validator ??
                  (value) {
                    if (isRequired && (value == null || value.trim().isEmpty)) {
                      return 'This field is required';
                    }
                    if (maxWords != null && value != null) {
                      final wordCount =
                          value.trim().split(RegExp(r'\s+')).length;
                      if (wordCount > maxWords)
                        return 'Max $maxWords words allowed';
                    }
                    return null;
                  },
            ),
            const SizedBox(height: 14),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final descText = _controller.descriptionController.text.trim();
    final descWordCount =
        descText.isEmpty ? 0 : descText.split(RegExp(r'\s+')).length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Brand Sign-Up",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Fill in the details below to register your brand.",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),

                _buildField(
                  label: "Brand Name",
                  controller: _controller.brandNameController,
                  isRequired: true,
                ),
                _buildField(
                  label: "Email",
                  controller: _controller.emailController,
                  isRequired: true,
                ),
                _buildField(
                  label: "Password",
                  controller: _controller.passwordController,
                  isRequired: true,
                  isPassword: true,
                ),
                _buildField(
                  label: "Confirm Password",
                  controller: _controller.confirmPasswordController,
                  isRequired: true,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    if (value != _controller.passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                _buildField(
                  label: "Description",
                  controller: _controller.descriptionController,
                  isRequired: true,
                  maxLines: 3,
                  maxWords: 30,
                  hint: "Tell us about your brand (max 30 words)",
                ),
                Text(
                  "$descWordCount / 30 words",
                  style: TextStyle(
                    fontSize: 12,
                    color: descWordCount > 30 ? Colors.red : Colors.grey,
                  ),
                ),
                const SizedBox(height: 14),

                _buildField(
                  label: "Contact Info",
                  controller: _controller.contactController,
                ),
                _buildField(
                  label: "Shipping Info",
                  controller: _controller.shippingInfoController,
                  isRequired: true,
                  hint: "e.g., Worldwide or Pakistan, UAE, UK",
                ),
                _buildField(
                  label: "Country of Origin",
                  controller: _controller.countryController,
                ),

                const SizedBox(height: 12),
                const Text(
                  "Upload Brand Logo",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickLogo,
                      icon: const Icon(Icons.upload),
                      label: const Text("Choose File"),
                    ),
                    const SizedBox(width: 10),
                    if (_logo != null)
                      Expanded(
                        child: Text(
                          _logo!.name,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                CheckboxListTile(
                  value: _agreeToTerms,
                  onChanged:
                      (val) => setState(() => _agreeToTerms = val ?? false),
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text("I agree to the "),
                      GestureDetector(
                        onTap: () => _showTermsDialog(context),
                        child: Text(
                          "Terms & Conditions",
                          style: TextStyle(
                            color: Colors.brown.shade700,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(" and "),
                      GestureDetector(
                        onTap: () => _showTermsDialog(context),
                        child: Text(
                          "Privacy Policy",
                          style: TextStyle(
                            color: Colors.brown.shade700,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.brown,
                ),

                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Submit Application",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

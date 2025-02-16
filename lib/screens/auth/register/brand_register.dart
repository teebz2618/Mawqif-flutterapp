import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import '../controllers/brand_signup_controller.dart';

class BrandSignUpScreen extends StatefulWidget {
  const BrandSignUpScreen({super.key});

  @override
  State<BrandSignUpScreen> createState() => _BrandSignUpScreenState();
}

class _BrandSignUpScreenState extends State<BrandSignUpScreen> {
  final BrandSignUpController _controller = Get.put(BrandSignUpController());
  final _formKey = GlobalKey<FormState>();
  bool _agreeToTerms = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  final RxBool _shippingErrorVisible = false.obs;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _controller.descriptionController.addListener(() {
      setState(() {}); // For live word count
    });

    ever(_controller.isWorldwide, (_) => _validateShippingInfo());
    ever(_controller.selectedCountries, (_) => _validateShippingInfo());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
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

  bool _validateShippingInfo() {
    final isValid =
        _controller.isWorldwide.value ||
        _controller.selectedCountries.isNotEmpty;
    _shippingErrorVisible.value = !isValid;
    return isValid;
  }

  void _handleSignUp() {
    setState(() {
      _autoValidateMode = AutovalidateMode.onUserInteraction;
    });

    if (!_formKey.currentState!.validate() || !_validateShippingInfo()) return;

    if (!_agreeToTerms) {
      Get.snackbar(
        "Terms Required",
        "Please agree to Terms & Policies.",
        backgroundColor: Colors.brown.shade100,
      );
      return;
    }
    _controller.signUpWithEmail(
      onSuccess: () => Get.offAllNamed('/brandPending'),
      onError:
          (message) => Get.snackbar(
            "Sign Up Failed",
            message,
            backgroundColor: Colors.red.shade100,
          ),
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
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    String? Function(String?)? validator,
    String? prefixText,
    AutovalidateMode? autovalidateMode,
  }) {
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
                    : [
                      const TextSpan(
                        text: ' (optional)',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          maxLines: isPassword ? 1 : maxLines,
          autovalidateMode: autovalidateMode ?? _autoValidateMode,
          decoration: InputDecoration(
            hintText: hint ?? label,
            prefixText: prefixText,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20,
            ),
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: onToggleObscure,
                    )
                    : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
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
                if (isRequired && (value == null || value.trim().isEmpty))
                  return 'This field is required';
                if (maxWords != null && value != null) {
                  final wordCount = value.trim().split(RegExp(r'\s+')).length;
                  if (wordCount > maxWords)
                    return 'Max $maxWords words allowed';
                }
                return null;
              },
        ),
        const SizedBox(height: 14),
      ],
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Brand name is required';
                    if (!RegExp(r'[a-zA-Z]').hasMatch(value))
                      return 'Brand name must contain at least one letter';
                    return null;
                  },
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
                  obscureText: _obscurePassword,
                  onToggleObscure:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                ),

                _buildField(
                  label: "Confirm Password",
                  controller: _controller.confirmPasswordController,
                  isRequired: true,
                  isPassword: true,
                  obscureText: _obscureConfirmPassword,
                  onToggleObscure:
                      () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'This field is required';
                    if (value != _controller.passwordController.text)
                      return 'Passwords do not match';
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Description is required';
                    final words = value.trim().split(RegExp(r'\s+'));
                    if (words.length > 30) return 'Maximum 30 words allowed';
                    return null;
                  },
                ),
                Text(
                  "$descWordCount / 30 words",
                  style: TextStyle(
                    fontSize: 12,
                    color: descWordCount > 30 ? Colors.red : Colors.grey,
                  ),
                ),

                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: "Country of Origin",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _controller.countryController,
                      readOnly: true,
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: false,
                          onSelect: (country) {
                            setState(() {
                              _controller.countryController.text = country.name;
                              _controller.selectedDialCode = country.phoneCode;
                            });
                          },
                        );
                      },
                      autovalidateMode: _autoValidateMode,
                      validator:
                          (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Please select a country'
                                  : null,
                      decoration: InputDecoration(
                        hintText: "Select your country",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _buildField(
                  label: "Contact Info",
                  controller: _controller.contactController,
                  isRequired: false,
                  hint: "Phone number",
                  prefixText:
                      _controller.selectedDialCode != null
                          ? '+${_controller.selectedDialCode} '
                          : null,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                        return 'Enter digits only';
                      }
                    }
                    return null;
                  },
                ),

                const Text(
                  "Shipping Info",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Obx(
                  () => CheckboxListTile(
                    title: const Text("Ship Worldwide"),
                    value: _controller.isWorldwide.value,
                    onChanged: (val) {
                      _controller.isWorldwide.value = val ?? false;
                      if (val == true) _controller.selectedCountries.clear();
                    },
                    activeColor: Colors.brown,
                  ),
                ),

                Obx(
                  () => IgnorePointer(
                    ignoring: _controller.isWorldwide.value,
                    child: Opacity(
                      opacity: _controller.isWorldwide.value ? 0.5 : 1.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              showCountryPicker(
                                context: context,
                                showPhoneCode: false,
                                onSelect: (country) {
                                  if (!_controller.selectedCountries.contains(
                                    country.name,
                                  )) {
                                    _controller.selectedCountries.add(
                                      country.name,
                                    );
                                  }
                                },
                              );
                            },
                            icon: const Icon(Icons.add_location_alt),
                            label: const Text("Select Countries"),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children:
                                _controller.selectedCountries.map((country) {
                                  return Chip(
                                    label: Text(country),
                                    onDeleted:
                                        () => _controller.selectedCountries
                                            .remove(country),
                                    deleteIconColor: Colors.red,
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 14),

                          Obx(() {
                            return _shippingErrorVisible.value
                                ? const Padding(
                                  padding: EdgeInsets.only(top: 4, left: 4),
                                  child: Text(
                                    'Please select "Ship Worldwide" or add at least one country.',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                                : const SizedBox.shrink();
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

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

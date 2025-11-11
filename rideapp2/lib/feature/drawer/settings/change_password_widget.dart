import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridesharing/common/constant/assets.dart';
import 'package:ridesharing/common/utils/snackbar_utils.dart';
import 'package:ridesharing/common/widget/common_container.dart';
import 'package:ridesharing/common/widget/common_popup_box.dart';
import 'package:ridesharing/common/widget/custom_text_field.dart';
import 'package:ridesharing/common/widget/form_validator.dart';
import 'package:ridesharing/feature/auth/login/login_page.dart';
import 'package:ridesharing/common/services/auth_service.dart';

class ChangePasswordWidget extends StatefulWidget {
  const ChangePasswordWidget({super.key});

  @override
  State<ChangePasswordWidget> createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget> {
  bool showOldPassword = true;
  bool showNewPassword = true;
  bool showConfirmPassword = true;
  
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      onButtonPressed: _changePassword,
      buttonName: "Save Changes",
      appBarTitle: "Change Password",
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Updating your password...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeaderSection(),
                  const SizedBox(height: 32),
                  
                  // Password Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildPasswordField(
                          controller: _oldPasswordController,
                          label: "Current Password",
                          hintText: "Enter your current password",
                          isVisible: showOldPassword,
                          onToggleVisibility: () {
                            setState(() {
                              showOldPassword = !showOldPassword;
                            });
                          },
                          validator: (value) =>
                              FormValidator.validateFieldNotEmpty(value, "Current Password"),
                        ),
                        const SizedBox(height: 20),
                        
                        _buildPasswordField(
                          controller: _newPasswordController,
                          label: "New Password",
                          hintText: "Enter your new password",
                          isVisible: showNewPassword,
                          onToggleVisibility: () {
                            setState(() {
                              showNewPassword = !showNewPassword;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter new password";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          label: "Confirm New Password",
                          hintText: "Re-enter your new password",
                          isVisible: showConfirmPassword,
                          onToggleVisibility: () {
                            setState(() {
                              showConfirmPassword = !showConfirmPassword;
                            });
                          },
                          validator: (value) {
                            if (_newPasswordController.text != value) {
                              return "Password does not match";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Password Requirements
                  const SizedBox(height: 24),
                  _buildPasswordRequirements(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                Colors.green.withOpacity(0.1),
                Colors.white,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 40,
              color: Colors.green.shade600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Title
        Text(
          "Change Password",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
        const SizedBox(height: 8),
        
        // Description
        Text(
          "Create a strong password to secure your account. Make sure it's different from your previous passwords.",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        ReusableTextField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: controller,
          validator: validator,
          showSurfixIcon: true,
          onSuffixPressed: onToggleVisibility,
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SvgPicture.asset(
              isVisible ? Assets.eyeIcon : Assets.eyeOffIcon,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                Colors.grey.shade600,
                BlendMode.srcIn,
              ),
            ),
          ),
          hintText: hintText,
          obscureText: isVisible,
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.shade100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: Colors.green.shade600,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "Password Requirements",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRequirementItem(
            "At least 6 characters long",
            Icons.check_circle_outline_rounded,
          ),
          const SizedBox(height: 6),
          _buildRequirementItem(
            "Different from previous passwords",
            Icons.check_circle_outline_rounded,
          ),
          const SizedBox(height: 6),
          _buildRequirementItem(
            "Easy to remember but hard to guess",
            Icons.check_circle_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.green.shade500,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final navigator = Navigator.of(context);

      try {
        bool success = await _authService.changePassword(
          AuthService.currentUserId!,
          _newPasswordController.text,
        );

        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
        });

        if (success) {
          showCommonPopUpDialog(
            context: context,
            message: "Password changed successfully.",
            title: "Success",
            onEnablePressed: () {
              _authService.logout();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginWidget()),
                (route) => false,
              );
            },
            imageUrl: Assets.successAlertImage,
            enableButtonName: "Back to Login",
          );
        } else {
          SnackBarUtils.showErrorBar(
            context: context,
            message: "Failed to change password",
          );
        }
      } catch (e) {
        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
        });
        SnackBarUtils.showErrorBar(
          context: context,
          message: "An error occurred. Please try again.",
        );
      }
    }
  }
}
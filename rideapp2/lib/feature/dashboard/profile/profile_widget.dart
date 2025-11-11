import 'package:flutter/material.dart';
import 'package:ridesharing/app/text_style.dart';
import 'package:ridesharing/common/theme.dart';
import 'package:ridesharing/common/utils/size_utils.dart';
import 'package:ridesharing/common/utils/snackbar_utils.dart';
import 'package:ridesharing/common/widget/common_container.dart';
import 'package:ridesharing/common/widget/custom_button.dart';
import 'package:ridesharing/common/widget/custom_text_field.dart';
import 'package:ridesharing/feature/auth/login/login_page.dart';
import 'package:ridesharing/common/services/auth_service.dart';
import 'package:ridesharing/common/model/user_model.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final genderController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();

  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;
  bool _isEditing = false;
  
  // REMPLACER late PAR ? ET INITIALISER DANS initState
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
  }

  void _initializeAnimations() {
    // INITIALISER LES ANIMATIONS AVEC DES VALEURS PAR DÉFAUT
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
    
    _animationController!.forward();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = await _authService.getCurrentUser();
      if (user != null) {
        if (mounted) {
          setState(() {
            _currentUser = user;
            nameController.text = user.name;
            emailController.text = user.email;
            phoneNumberController.text = user.phoneNumber;
            genderController.text = user.gender;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    nameController.dispose();
    emailController.dispose();
    genderController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      appBarTitle: "Profile",
      body: _isLoading
          ? _buildLoadingState()
          : _buildProfileContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.appColor),
          ),
          const SizedBox(height: 16),
          Text(
            "Loading your profile...",
            style: PoppinsTextStyles.titleMediumRegular.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    // VÉRIFIER SI LES ANIMATIONS SONT INITIALISÉES
    if (_animationController == null || _scaleAnimation == null || _fadeAnimation == null) {
      return _buildLoadingState();
    }

    return AnimatedBuilder(
      animation: _animationController!,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation!,
          child: ScaleTransition(
            scale: _scaleAnimation!,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ----------- HEADER SECTION -----------
                  _buildHeaderSection(),
                  const SizedBox(height: 30),

                  // ----------- PROFILE CARD -----------
                  _buildProfileCard(),

                  const SizedBox(height: 35),

                  // ----------- ACTION BUTTONS -----------
                  _buildActionButtons(),

                  SizedBox(height: 25.hp),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        // Avatar avec effet de hover
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _isEditing ? _showAvatarOptions : null,
            child: _buildAvatarWithInitials(),
          ),
        ),
        const SizedBox(height: 8),
        
        // Nom avec effet de transition
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _currentUser?.name ?? "N/A",
            key: ValueKey(_currentUser?.name),
            style: PoppinsTextStyles.titleMediumRegular.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        // Information d'inscription
        if (_currentUser?.registrationCountry != null)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _isEditing ? 0.6 : 1.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey[600],
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Inscrit depuis ${_currentUser!.registrationCountry}",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isEditing
              ? CustomTheme.appColor.withOpacity(0.4)
              : Colors.grey.withOpacity(0.2),
          width: _isEditing ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isEditing ? 0.08 : 0.06),
            blurRadius: _isEditing ? 16 : 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSectionTitle("Personal Information"),
          const SizedBox(height: 10),

          _buildTextFieldWithValidation(
            "Name", 
            nameController, 
            !_isEditing,
            validator: (value) => value?.isEmpty == true ? "Name is required" : null,
          ),
          SizedBox(height: 14.hp),

          _buildTextFieldWithValidation(
            "Email", 
            emailController, 
            true,
            validator: (value) {
              if (value?.isEmpty == true) return "Email is required";
              if (value != null && !value.contains('@')) return "Enter a valid email";
              return null;
            },
          ),
          SizedBox(height: 14.hp),

          _buildTextFieldWithValidation(
            "Mobile Number", 
            phoneNumberController, 
            !_isEditing,
            validator: (value) => value?.isEmpty == true ? "Phone number is required" : null,
          ),
          SizedBox(height: 14.hp),

          _buildGenderField(),
          SizedBox(height: 14.hp),

          _buildTextFieldWidget("Address", addressController, !_isEditing),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithValidation(
    String label, 
    TextEditingController controller, 
    bool readOnly, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        ReusableTextField(
          controller: controller,
          hintText: label,
          readOnly: readOnly,
          validator: _isEditing ? validator : null,
        ),
      ],
    );
  }

  Widget _buildTextFieldWidget(String label, TextEditingController controller, bool readOnly) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        ReusableTextField(
          controller: controller,
          hintText: label,
          readOnly: readOnly,
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gender",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        ReusableTextField(
          suffixIcon: _isEditing 
              ? Icon(Icons.keyboard_arrow_down_outlined, color: CustomTheme.appColor)
              : null,
          controller: genderController,
          hintText: "Gender",
          readOnly: !_isEditing,
          onTap: _isEditing
              ? () {
                  _showGenderSelectionDialog();
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: _isEditing
          ? Column(
              key: const ValueKey("editMode"),
              children: [
                CustomRoundedButtom(
                  title: "Save Changes",
                  onPressed: _validateAndUpdateProfile,
                ),
                SizedBox(height: 12.hp),
                CustomRoundedButtom(
                  title: "Cancel",
                  color: Colors.grey.shade300,
                  textColor: Colors.grey.shade700,
                  onPressed: _cancelEditing,
                ),
              ],
            )
          : Column(
              key: const ValueKey("viewMode"),
              children: [
                CustomRoundedButtom(
                  title: "Edit Profile",
                  color: CustomTheme.appColor,
                  onPressed: () {
                    setState(() => _isEditing = true);
                    _animationController?.forward(from: 0.0);
                  },
                ),
                SizedBox(height: 12.hp),
                Row(
                  children: [
                    Expanded(
                      child: CustomRoundedButtom(
                        title: "Logout",
                        color: Colors.transparent,
                        onPressed: _showLogoutConfirmation,
                        textColor: CustomTheme.appColor,
                        borderColor: CustomTheme.appColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Bouton supplémentaire pour les fonctionnalités avancées
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                        onPressed: _showMoreOptions,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: CustomTheme.appColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline, color: CustomTheme.appColor, size: 18),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: PoppinsTextStyles.titleMediumRegular.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: CustomTheme.appColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWithInitials() {
    final String initials = _getUserInitials();
    final Color avatarColor = _getAvatarColor(_currentUser?.name ?? "");

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: 130,
      width: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: avatarColor,
        boxShadow: [
          BoxShadow(
            color: avatarColor.withOpacity(0.35),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
          if (_isEditing)
            BoxShadow(
              color: CustomTheme.appColor.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 3,
            ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                initials,
                key: ValueKey(initials),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          if (_isEditing)
            Positioned(
              bottom: 6,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Icon(
                  Icons.edit,
                  color: CustomTheme.appColor,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // -------- NOUVELLES MÉTHODES AMÉLIORÉES --------

  void _showGenderSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Gender", style: TextStyle(color: CustomTheme.appColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: genderList.map((gender) {
            return ListTile(
              leading: Icon(
                _getGenderIcon(gender),
                color: CustomTheme.appColor,
              ),
              title: Text(gender),
              onTap: () {
                setState(() {
                  genderController.text = gender;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'male': return Icons.male;
      case 'female': return Icons.female;
      default: return Icons.transgender;
    }
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Change Avatar", style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CustomTheme.appColor,
            )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAvatarOption(Icons.photo_camera, "Camera", _takePhoto),
                _buildAvatarOption(Icons.photo_library, "Gallery", _pickFromGallery),
                _buildAvatarOption(Icons.refresh, "Regenerate", _regenerateAvatar),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: CustomTheme.appColor.withOpacity(0.1),
          child: IconButton(
            icon: Icon(icon, color: CustomTheme.appColor),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }

  void _takePhoto() {
    // Implémentation de la prise de photo
    Navigator.pop(context);
    SnackBarUtils.showInfoBar(context: context, message: "Camera feature coming soon");
  }

  void _pickFromGallery() {
    // Implémentation de la sélection depuis la galerie
    Navigator.pop(context);
    SnackBarUtils.showInfoBar(context: context, message: "Gallery feature coming soon");
  }

  void _regenerateAvatar() {
    setState(() {
      // Régénérer les initiales
      if (_currentUser != null) {
        _currentUser = _createUpdatedUser(
          _currentUser!,
          avatarInitials: _generateInitials(nameController.text),
        );
      }
    });
    Navigator.pop(context);
    SnackBarUtils.showSuccessBar(context: context, message: "Avatar regenerated");
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout", style: TextStyle(color: CustomTheme.appColor)),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.security, color: CustomTheme.appColor),
              title: const Text("Privacy Settings"),
              onTap: () {
                Navigator.pop(context);
                _showPrivacySettings();
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline, color: CustomTheme.appColor),
              title: const Text("Help & Support"),
              onTap: () {
                Navigator.pop(context);
                _showHelpSupport();
              },
            ),
            ListTile(
              leading: Icon(Icons.bug_report, color: CustomTheme.appColor),
              title: const Text("Debug Info"),
              onTap: () {
                Navigator.pop(context);
                _showApiInfo();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings() {
    SnackBarUtils.showInfoBar(context: context, message: "Privacy settings coming soon");
  }

  void _showHelpSupport() {
    SnackBarUtils.showInfoBar(context: context, message: "Help & support coming soon");
  }

  void _validateAndUpdateProfile() {
    if (nameController.text.isEmpty) {
      SnackBarUtils.showErrorBar(context: context, message: "Please enter your name");
      return;
    }
    if (phoneNumberController.text.isEmpty) {
      SnackBarUtils.showErrorBar(context: context, message: "Please enter your phone number");
      return;
    }
    _updateProfile();
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _loadUserData(); // Recharger les données originales
    });
  }

  // -------- MÉTHODES EXISTANTES (AMÉLIORÉES) --------

  String _getUserInitials() {
    if (_currentUser?.avatarInitials != null && _currentUser!.avatarInitials!.isNotEmpty) {
      return _currentUser!.avatarInitials!;
    }
    return _generateInitials(_currentUser?.name ?? "User");
  }

  String _generateInitials(String name) {
    final names = name.split(' ').where((name) => name.isNotEmpty).toList();
    if (names.length >= 3) {
      return '${names[0][0]}${names[1][0]}${names[2][0]}'.toUpperCase();
    } else if (names.length == 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.length == 1 && names[0].length >= 2) {
      return names[0].substring(0, 2).toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  Color _getAvatarColor(String name) {
    final colors = [
      CustomTheme.appColor,
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.teal.shade700,
      Colors.red.shade700,
      Colors.indigo.shade700,
    ];
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  User _createUpdatedUser(User currentUser, {String? avatarInitials}) {
    return User(
      id: currentUser.id,
      name: currentUser.name,
      email: currentUser.email,
      phoneNumber: currentUser.phoneNumber,
      gender: currentUser.gender,
      password: currentUser.password,
      avatarInitials: avatarInitials ?? currentUser.avatarInitials,
      registrationIp: currentUser.registrationIp,
      registrationCountry: currentUser.registrationCountry,
    );
  }

  Future<void> _updateProfile() async {
    if (_currentUser != null) {
      User updatedUser = User(
        id: _currentUser!.id,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        gender: genderController.text,
        password: _currentUser!.password,
        avatarInitials: _generateInitials(nameController.text.trim()),
        registrationIp: _currentUser!.registrationIp,
        registrationCountry: _currentUser!.registrationCountry,
      );

      bool success = await _authService.updateProfile(updatedUser);

      if (!mounted) return;

      if (success) {
        setState(() {
          _isEditing = false;
          _currentUser = updatedUser;
        });
        SnackBarUtils.showSuccessBar(
          context: context,
          message: "Profile updated successfully!",
        );
      } else {
        SnackBarUtils.showErrorBar(
          context: context,
          message: "Failed to update profile",
        );
      }
    }
  }

  void _logout() {
    _authService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginWidget()),
      (route) => false,
    );
  }

  void _showApiInfo() {
    _authService.debugApiUsage();
    SnackBarUtils.showSuccessBar(
      context: context,
      message: "Check debug console for API information",
    );
  }

  final List<String> genderList = const ["Male", "Female", "Other"];
}
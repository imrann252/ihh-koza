import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';
import 'main_shell.dart';
import 'leader_map_screen.dart';
import 'hq_screen.dart';
import 'role_selection_view.dart';

// ─── Kullanıcı Rolleri ────────────────────────────────────────────────────────
// UserRole enum is now imported from app_state.dart

class _RoleOption {
  final UserRole role;
  final String title;
  final IconData icon;
  const _RoleOption({required this.role, required this.title, required this.icon});
}

const List<_RoleOption> _roleOptions = [
  _RoleOption(role: UserRole.gonullu, title: 'Gönüllü', icon: Icons.person_outline),
  _RoleOption(role: UserRole.ekipLideri, title: 'Ekip Lideri', icon: Icons.supervisor_account_outlined),
  _RoleOption(role: UserRole.genelMerkez, title: 'Genel Merkez', icon: Icons.hub_outlined),
];

// ─── Mock Kullanıcılar (Offline Doğrulama) ────────────────────────────────────
const Map<String, String> _mockUsers = {
  '10000000001': 'koza2025',
  'saha@ihh.org.tr': 'koza2025',
  'lider@ihh.org.tr': 'koza2025',
  'merkez@ihh.org.tr': 'koza2025',
};

// ═══════════════════════════════════════════════════════════════════════════════
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identityCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  UserRole _selectedRole = UserRole.gonullu;
  bool _obscure = true;
  bool _isLoading = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _identityCtrl.dispose();
    _passwordCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ─── Offline Mock Auth ──────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    final identity = _identityCtrl.text.trim();
    final password = _passwordCtrl.text;
    final isValid = _mockUsers[identity] == password;

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Geçersiz kimlik bilgileri.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Giriş başarılı — Seçilen role göre uygun ekrana yönlendir
    if (mounted) {
      // Global AppState'e login kaydı
      AppStateProvider.of(context).login(
        identity,
        identity.contains('@') ? identity : '$identity@ihh.org.tr',
        _selectedRole,
      );

      // Doğrudan 3 rollü seçim ekranına yönlendiriyoruz
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleSelectionView()),
      );
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Şifremi Unuttum'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kayıtlı e-posta adresinizi veya TC Kimlik numaranızı girerek şifre sıfırlama talebi oluşturabilirsiniz.'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'E-Posta veya TC No',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Şifre sıfırlama bağlantısı gönderildi.'),
                  backgroundColor: AppColors.kozaGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.kozaGreen),
            child: const Text('Gönder', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRegisterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Gönüllü Kayıt Formu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(decoration: InputDecoration(labelText: 'Ad Soyad', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              const TextField(decoration: InputDecoration(labelText: 'TC Kimlik No', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              const TextField(decoration: InputDecoration(labelText: 'E-Posta', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Şifre', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Uzmanlık Alanı', border: OutlineInputBorder()),
                items: ['Arama Kurtarma', 'İlk Yardım', 'Lojistik', 'Haberleşme'].map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (_) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kayıt talebiniz alındı. Onay sonrasında giriş yapabilirsiniz.'),
                  backgroundColor: AppColors.kozaGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.kozaGreen),
            child: const Text('Kayıt Ol', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Logo ──────────────────────────────────────
                    _buildLogo(),
                    const SizedBox(height: 16),
                    const Text(
                      'İHH KOZA',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.kozaGreen, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'OPERASYON YÖNETİM SİSTEMİ',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary, letterSpacing: 2.0),
                    ),
                    const SizedBox(height: 36),

                    // ── Kimlik ────────────────────────────────────
                    _buildInput(
                      controller: _identityCtrl,
                      label: 'E-POSTA VEYA TC NO',
                      hint: '100*********',
                      prefixIcon: Icons.badge_outlined,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Şifre ─────────────────────────────────────
                    _buildInput(
                      controller: _passwordCtrl,
                      label: 'ŞİFRE',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSecondary, size: 22,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Şifre gerekli';
                        if (v.length < 4) return 'En az 4 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: const Text(
                          'Şifremi Unuttum',
                          style: TextStyle(color: AppColors.kozaGreen, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Rol Seçimi ────────────────────────────────
                    _buildRoleSelector(),
                    const SizedBox(height: 28),

                    // ── Giriş Butonu ──────────────────────────────
                    _buildLoginButton(),
                    const SizedBox(height: 20),

                    // ── Kayıt Ol ──────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Hesabınız yok mu? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        GestureDetector(
                          onTap: _showRegisterDialog,
                          child: const Text(
                            'Kayıt Ol',
                            style: TextStyle(
                              color: AppColors.kozaGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLogo() {
    return Container(
      width: 96, height: 96,
      decoration: BoxDecoration(
        color: AppColors.kozaGreenLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.kozaGreen.withAlpha(30), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/koza_pine_cone_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.eco, size: 48, color: AppColors.kozaGreen),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.0)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textSecondary.withAlpha(128), fontWeight: FontWeight.w400),
            prefixIcon: Icon(prefixIcon, color: AppColors.kozaGreen, size: 22),
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.inputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.inputBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.inputBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.kozaGreen, width: 1.8)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.red.shade400)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.red.shade400, width: 1.8)),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ROLÜNÜZÜ SEÇİN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.0)),
        const SizedBox(height: 12),
        ..._roleOptions.map(_buildRoleTile),
      ],
    );
  }

  Widget _buildRoleTile(_RoleOption opt) {
    final sel = _selectedRole == opt.role;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selectedRole = opt.role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            color: sel ? AppColors.kozaGreenLight : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: sel ? AppColors.kozaGreen : AppColors.divider, width: sel ? 2.0 : 1.2),
            boxShadow: sel ? [BoxShadow(color: AppColors.kozaGreen.withAlpha(25), blurRadius: 12, offset: const Offset(0, 4))] : [],
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: sel ? AppColors.kozaGreen.withAlpha(30) : AppColors.inputBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(opt.icon, color: sel ? AppColors.kozaGreen : AppColors.textSecondary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(opt.title, style: TextStyle(fontSize: 16, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, color: sel ? AppColors.kozaGreen : AppColors.textPrimary)),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 24, height: 24,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: sel ? AppColors.kozaGreen : AppColors.inputBorder, width: 2.0)),
                child: sel
                    ? Center(child: Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.kozaGreen)))
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kozaGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.kozaGreenMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sisteme Giriş Yap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }
}

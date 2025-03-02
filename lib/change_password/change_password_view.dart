import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapon_vending/change_password/change_password_view_model.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChangePasswordViewModel>(
      create: (_) => ChangePasswordViewModel(),
      child: Consumer<ChangePasswordViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: const Text('Password'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
             
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Change your password', style: TextStyle(color: Colors.white)),
                   const SizedBox(height: 16),
                  _buildPasswordField(
                    context: context,
                    label: 'Old Password',
                    onChanged: viewModel.updateOldPassword,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    context: context,
                    label: 'New Password',
                    onChanged: viewModel.updateNewPassword,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    context: context,
                    label: 'Confirm New Password',
                    onChanged: viewModel.updateConfirmPassword,
                  ),
                  const SizedBox(height: 16),
                  _buildRequirements(),
                  const SizedBox(height: 20),
                  // ElevatedButton(
                  //   onPressed: viewModel.isPasswordValid
                  //       ? () async {
                  //           await viewModel.updatePassword();
                  //           // Optionally pop or show success message
                  //           // Navigator.pop(context);
                  //         }
                  //       : null,
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.green,
                  //     minimumSize: const Size(double.infinity, 50),
                  //   ),
                  //   child: const Text('Update'),
                  // ),
                  SizedBox(height: 30),
                  Center(
                    child: Container(
                                  height: 55, // Added width to the button
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                    colors: [ Color.fromRGBO(1, 181, 1, 1), Color.fromRGBO(1, 135, 95, 1)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15), backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    ),
                                    onPressed: () {
                                    },
                                    child: Text("Update", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18)),
                                  ),
                                  ),),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required String label,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        TextField(
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.black,
            border: OutlineInputBorder(),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("Requirements:", style: TextStyle(color: Colors.white)),
        Text("• Minimum of 8 characters", style: TextStyle(color: Colors.white)),
        Text("• At least one special character (@!#\$%^&*)", style: TextStyle(color: Colors.white)),
        Text("• At least one number", style: TextStyle(color: Colors.white)),
      ],
    );
  }
}

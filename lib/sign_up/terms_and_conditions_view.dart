import 'package:flutter/material.dart';

class TermsAndConditionsView extends StatefulWidget {
  const TermsAndConditionsView({super.key});

  @override
  State<TermsAndConditionsView> createState() => _TermsAndConditionsViewState();
}

class _TermsAndConditionsViewState extends State<TermsAndConditionsView> {
  late ScrollController _scrollController;
  bool _hasReadTerms = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_checkIfReachedBottom);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkIfReachedBottom);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkIfReachedBottom() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_hasReadTerms) {
        setState(() {
          _hasReadTerms = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Terms and Conditions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTermsSection(
                      'Last Updated',
                      'May 11, 2026',
                    ),
                    const SizedBox(height: 20),
                    _buildTermsSection(
                      '1. Introduction',
                      'Welcome to Tapon Vending. These Terms and Conditions govern your use of our app and services. By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.',
                    ),
                    const SizedBox(height: 20),
                    _buildTermsSection(
                      '2. Use License',
                      'Permission is granted to temporarily download one copy of the materials (information or software) on Tapon Vending\'s app for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n• Modify or copy the materials\n• Use the materials for any commercial purpose or for any public display\n• Attempt to decompile or reverse engineer any software contained on the app\n• Remove any copyright or other proprietary notations from the materials\n• Transfer the materials to another person or "mirror" the materials on any other server',
                    ),
                    const SizedBox(height: 20),
                    _buildTermsSection(
                      '3. User Accounts',
                      'If you create an account with Tapon Vending, you are responsible for maintaining the confidentiality of your password and account information. You agree to accept responsibility for all activities that occur under your account. You must notify us immediately of any unauthorized use of your account.',
                    ),
                    const SizedBox(height: 20),
                    _buildTermsSection(
                      '4. Payment Terms',
                      'All transactions through our app are subject to acceptance and processing by our payment processor. We reserve the right to refuse or cancel any order at any time. Prices are subject to change without notice.',
                    ),
                    const SizedBox(height: 20),
                    _buildTermsSection(
                      '5. Limitation of Liability',
                      'In no event shall Tapon Vending or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on our app, even if we have been notified orally or in writing.',
                    ),
                    const SizedBox(height: 20),
                    _buildTermsSection(
                      '6. Accuracy of Materials',
                      'The materials appearing on Tapon Vending\'s app could include technical, typographical, or photographic errors. We do not warrant that any of the materials on our app are accurate, complete, or current.',
                    ),
                    const SizedBox(height: 20),
                    _buildTermsSection(
                      '7. Links',
                      'We have not reviewed all of the sites linked to our website and are not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by us of the site. Use of any such linked website is at the user\'s own risk.',
                    ),
                    const SizedBox(height: 20),
                    _buildTermsSection(
                      '8. Modifications',
                      'We may revise these Terms and Conditions for our app at any time without notice. By using this app, you are agreeing to be bound by the then current version of these Terms and Conditions.',
                    ),
                    const SizedBox(height: 20),
                    _buildTermsSection(
                      '9. Governing Law',
                      'These Terms and Conditions and the materials on Tapon Vending\'s app are governed by and construed in accordance with the laws applicable in your jurisdiction, and you irrevocably submit to the exclusive jurisdiction of the courts in that location.',
                    ),
                    const SizedBox(height: 20),
                    _buildTermsSection(
                      '10. Contact Information',
                      'If you have any questions about these Terms and Conditions, please contact us at support@taponvending.com',
                    ),
                    const SizedBox(height: 40),
                    // Scroll indicator
                    if (!_hasReadTerms)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: Colors.orange, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: const Text(
                                'Please scroll down to the end to agree',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(
                          color: Color.fromRGBO(1, 181, 1, 1), width: 2),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      'Disagree',
                      style: TextStyle(
                        color: Color.fromRGBO(1, 181, 1, 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _hasReadTerms
                            ? [
                                Color.fromRGBO(1, 181, 1, 1),
                                Color.fromRGBO(1, 135, 95, 1),
                              ]
                            : [
                                Colors.grey.withOpacity(0.5),
                                Colors.grey.withOpacity(0.5),
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: _hasReadTerms
                          ? () => Navigator.pop(context, true)
                          : null,
                      child: const Text(
                        'Agree',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            color: Color.fromRGBO(215, 215, 215, 1),
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

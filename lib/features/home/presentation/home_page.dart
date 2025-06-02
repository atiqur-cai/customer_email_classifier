import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:customer_email_classifier/features/home/data/data_sources/mock_llm_data_sources.dart';
import 'package:customer_email_classifier/features/home/presentation/widgets/custom_snakebar.dart';
import 'package:customer_email_classifier/features/home/data/models/email_message_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MockLlmDataSources _dataSources = MockLlmDataSources();
  final TextEditingController _emailInputController = TextEditingController();
  final List<EmailMessage> _emails = [];
  final Uuid _uuid = const Uuid();
  bool _isClassifying = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailInputController.dispose();
    super.dispose();
  }

  void _addEmails() {
    final emailContents =
        _emailInputController.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    setState(() {
      for (var content in emailContents) {
        _emails.insert(0, EmailMessage(id: _uuid.v4(), content: content));
      }
    });
  }

  Future<void> _classifyAllListedEmails() async {
    if (_isClassifying) return;

    setState(() {
      _isClassifying = true;
    });

    final emailsToClassify = List<EmailMessage>.from(_emails);

    for (int i = 0; i < _emails.length; i++) {
      if (!mounted) return;

      final email = emailsToClassify[i];
      try {
        final response = await _dataSources.classifyEmail(email.content);
        if (response.containsKey('tags') && response['tags'] is List) {
          setState(() {
            final originalEmail = _emails.firstWhere((e) => e.id == email.id);
            originalEmail.tags = List<String>.from(response['tags']);
          });
        }
      } catch (e) {
        setState(() {
          final originalEmail = _emails.firstWhere((e) => e.id == email.id);
          originalEmail.tags = ['Error: Classification Failed'];
        });
      }
    }

    setState(() {
      _isClassifying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Email Classifier'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                TextField(
                  controller: _emailInputController,
                  decoration: InputDecoration(
                    labelText: 'Enter new email message',
                    hintText: 'e.g., I need a refund for my last order.',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.purple),
                      onPressed: () => _emailInputController.clear(),
                    ),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_emailInputController.text.trim().isEmpty) {
                            showSnakeBar(ctx: context, text: 'Please enter an email message.', color: Colors.red);
                          } else {
                            _addEmails();
                            showSnakeBar(ctx: context, text: 'Email added to list.', color: Colors.green);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.purpleAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add Unclassified Emails'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_emails.isEmpty) {
                            showSnakeBar(ctx: context, text: 'No emails in the list to classify.', color: Colors.red);
                            return;
                          }
                          if (_isClassifying) {
                            showSnakeBar(ctx: context, text: 'Classification Processing.', color: Colors.deepOrange);
                          } else {
                            _classifyAllListedEmails();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: _isClassifying ? Colors.grey : Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        child: _isClassifying
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Classifying...'),
                                ],
                              )
                            : const Text('Classify Input Email'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Classified Emails (${_emails.length})',
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: _emails.length,
              itemBuilder: (context, index) {
                final email = _emails[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID: ${email.id.substring(0, 8)}',
                          style: const TextStyle(fontSize: 12, color: Colors.black45),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Email: ${email.content}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'Tags: ${email.tagsDisplay}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

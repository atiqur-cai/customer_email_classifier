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
  List<EmailMessage> _emails = [];
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

  void _setDemoStrings() {
    _emailInputController.clear();
    _emailInputController.text = """I've been charged twice and I need my money back.
The app crashed when I tried to upload a photo. It's a critical bug report!
Just wanted to say how much I love your service! It's fantastic.
My order hasn't arrived yet, and the tracking number isn't updating. This is a shipping/delivery issue.
Could you add a dark mode feature? It would be great for night usage.
I can't log in to my account. I keep getting an error message. I need technical support.
I'm interested in purchasing your enterprise solution. Can someone contact me about sales inquiries?
I received a suspicious email asking for my login credentials. This looks like a security concern.
Claim your free prize now! Click here to redeem. This is definitely spam.
I need a refund for the item I bought last week. It didn't meet my expectations.
The website is so slow, it takes ages to load anything. This is a major complaint.
I found a typo on your pricing page. (no specific tag for this, will go to Other)
My delivery was delayed due to a bad address. Can you help?
I lost my password. Please send me a new one.
""";
  }

  void _setDemoSingleString() {
    _emailInputController.clear();
    _emailInputController.text = "I've been charged twice and I need my money back.";
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
                  maxLines: 3,
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
                    const SizedBox(width: 8),
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _setDemoSingleString();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.black26,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('1 Emails'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _setDemoStrings();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.black45,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Multi Emails'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _emails = [];
                            _emailInputController.clear();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Clear all'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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

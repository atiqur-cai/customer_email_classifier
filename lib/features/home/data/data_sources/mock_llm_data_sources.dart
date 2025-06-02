import 'package:dio/dio.dart';

class MockLlmDataSources {
  // When we use real then call via Dio to
  final Dio _dio = Dio();

  final List<String> _possibleTags = const [
    "Bug Report",
    "Billing Issue",
    "Praise",
    "Complaint",
    "Feature Request",
    "Technical Support",
    "Sales Inquiry",
    "Security Concern",
    "Spam/Irrelevant",
    "Refund Request",
    "Shipping/Delivery",
    "Other"
  ];

  Future<Map<String, dynamic>> classifyEmail(String message) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final lowerCaseMessage = message.toLowerCase();
    final List<String> assignedTags = [];

    if (lowerCaseMessage.contains('bug') || lowerCaseMessage.contains('error') || lowerCaseMessage.contains('glitch')) {
      assignedTags.add("Bug Report");
    }
    if (lowerCaseMessage.contains('charged') ||
        lowerCaseMessage.contains('bill') ||
        lowerCaseMessage.contains('invoice')) {
      assignedTags.add("Billing Issue");
    }
    if (lowerCaseMessage.contains('great') ||
        lowerCaseMessage.contains('awesome') ||
        lowerCaseMessage.contains('love')) {
      assignedTags.add("Praise");
    }
    if (lowerCaseMessage.contains('unhappy') ||
        lowerCaseMessage.contains('frustrated') ||
        lowerCaseMessage.contains('poor service')) {
      assignedTags.add("Complaint");
    }
    if (lowerCaseMessage.contains('feature') ||
        lowerCaseMessage.contains('suggest') ||
        lowerCaseMessage.contains('idea')) {
      assignedTags.add("Feature Request");
    }
    if (lowerCaseMessage.contains('help') ||
        lowerCaseMessage.contains('fix') ||
        lowerCaseMessage.contains('troubleshoot')) {
      assignedTags.add("Technical Support");
    }
    if (lowerCaseMessage.contains('buy') ||
        lowerCaseMessage.contains('price') ||
        lowerCaseMessage.contains('interested')) {
      assignedTags.add("Sales Inquiry");
    }
    if (lowerCaseMessage.contains('security') ||
        lowerCaseMessage.contains('breach') ||
        lowerCaseMessage.contains('password')) {
      assignedTags.add("Security Concern");
    }
    if (lowerCaseMessage.contains('spam') ||
        lowerCaseMessage.contains('unwanted') ||
        lowerCaseMessage.contains('unsubscribe')) {
      assignedTags.add("Spam/Irrelevant");
    }
    if (lowerCaseMessage.contains('refund') || lowerCaseMessage.contains('money back')) {
      assignedTags.add("Refund Request");
    }
    if (lowerCaseMessage.contains('shipping') ||
        lowerCaseMessage.contains('delivery') ||
        lowerCaseMessage.contains('track order')) {
      assignedTags.add("Shipping/Delivery");
    }
    if (assignedTags.isEmpty) {
      assignedTags.add("Other");
    }

    final uniqueTags = assignedTags.toSet().toList();
    return {"tags": uniqueTags};
  }

  /// Constructs the prompt string for the LLM.
  String buildLlmPrompt(String message) {
    final tagsString = _possibleTags.join(', ');
    return """
    You are an AI assistant. Classify this customer message into one or more of: $tagsString
    Message: "$message"
    Response format: {"tags": ["Tag1", "Tag2"]}
    """;
  }

  callLLMWithPrompt(String message) {
    //TODO: Implement real LLM prompt call
    _dio.post('path');
  }
}

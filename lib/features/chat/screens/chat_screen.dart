import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final bool showBottomNav;

  const ChatScreen({super.key, this.showBottomNav = true});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    _controller.clear();
    setState(() {
      _messages.add(ChatMessage(sender: MessageSender.user, text: text));
      _isLoading = true;
    });
    _scrollToBottom();

    final reply = await ChatService.sendMessage(text);

    setState(() {
      _messages.add(reply);
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F1),
        elevation: 0,
        title: const Text(
          'Ask AI',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) =>
                        _MessageBubble(message: _messages[index]),
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFF6B4A),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Swipe2Eat AI is thinking...',
                    style: TextStyle(
                        color: Color(0xFF9CA3AF), fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          _InputBar(
            controller: _controller,
            isLoading: _isLoading,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant_menu,
              size: 56, color: Color(0xFFFF6B4A)),
          SizedBox(height: 16),
          Text(
            'Ask me for food recommendations!',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'e.g. "I want something spicy and cheap"',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser
                  ? const Color(0xFFFF6B4A)
                  : const Color(0xFFFFEDE6),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: isUser
                    ? Colors.white
                    : const Color(0xFF1F2937),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          if (message.recommendations.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...message.recommendations
                .map((r) => _RecommendationCard(rec: r)),
          ],
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final FoodRecommendation rec;

  const _RecommendationCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD5C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rec.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.attach_money,
                  size: 14, color: Color(0xFF6B7280)),
              Text(
                rec.price.toStringAsFixed(2),
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(width: 10),
              const Text('🌶️',
                  style: TextStyle(fontSize: 12)),
              Text(
                ' ${rec.spiceLevel}',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.restaurant,
                  size: 14, color: Color(0xFF6B7280)),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  rec.cuisine,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (rec.reasons.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              rec.reasons.join(' · '),
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: 'What are you craving?',
                  hintStyle:
                      const TextStyle(color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                        color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                        color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                        color: Color(0xFFFF6B4A)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isLoading ? null : onSend,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isLoading
                      ? const Color(0xFFE5E7EB)
                      : const Color(0xFFFF6B4A),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: isLoading ? const Color(0xFF9CA3AF) : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ["All", "Services", "General", "Account"];
  String _selectedCategory = "All";

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            _categories.map((cat) {
              final selected = cat == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      color:
                          selected
                              ? Colors.brown.shade900
                              : Colors.brown.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: selected,
                  selectedColor: Colors.brown.shade400,
                  backgroundColor: Colors.brown.shade100,
                  showCheckmark: false, // removes the tick mark
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget buildFAQTab() {
    final allFAQs = [
      {
        "question": "Can I track my order’s delivery status?",
        "answer":
            "Yes, you can track your order from the 'My Orders' section in your profile.",
      },
      {
        "question": "Is there a return policy?",
        "answer":
            "Yes, we offer a 7-day return policy for unused and undamaged products.",
      },
      {
        "question": "How do I contact customer support?",
        "answer":
            "You can contact our support via chat, WhatsApp, or email through the Help Center.",
      },
    ];

    final servicesFAQs = [
      {
        "question": "What services does Mawqif offer?",
        "answer":
            "Mawqif allows you to browse and shop abayas, thobes, and more from multiple brands.",
      },
      {
        "question": "Do you offer custom sizing?",
        "answer":
            "Yes, many of our partner brands support custom sizes during checkout.",
      },
    ];

    final generalFAQs = [
      {
        "question": "What payment methods are accepted?",
        "answer":
            "We accept Visa, MasterCard, COD (in select regions), and bank transfer.",
      },
      {
        "question": "How to add a review?",
        "answer":
            "Go to 'My Orders', select the product and tap 'Write a Review'.",
      },
    ];

    final accountFAQs = [
      {
        "question": "How do I update my account details?",
        "answer":
            "Go to the Profile screen and tap on 'Your Profile' to update details.",
      },
      {
        "question": "Can I save my favorite items for later?",
        "answer":
            "Yes, tap the heart icon on any product to save it to your wishlist.",
      },
    ];

    final faqMap = {
      "All": [...allFAQs, ...servicesFAQs, ...generalFAQs, ...accountFAQs],
      "Services": servicesFAQs,
      "General": generalFAQs,
      "Account": accountFAQs,
    };

    final selectedFaqs = faqMap[_selectedCategory]!;

    return Column(
      children: [
        const SizedBox(height: 10),
        buildCategoryChips(),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: selectedFaqs.length,
            itemBuilder: (context, index) {
              final faq = selectedFaqs[index];
              return ExpansionTile(
                iconColor: Colors.brown.shade700,
                collapsedIconColor: Colors.brown.shade400,
                title: Text(
                  faq["question"]!,
                  style: TextStyle(
                    color: Colors.brown.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      faq["answer"]!,
                      style: TextStyle(color: Colors.brown.shade600),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildContactTab() {
    final contacts = [
      {
        "title": "Customer Service",
        "icon": Icons.support_agent,
        "content":
            "Our customer support team is available 24/7 to help you with any questions or issues.",
      },
      {
        "title": "WhatsApp",
        "icon": FontAwesomeIcons.whatsapp,
        "content":
            "Chat with us directly on WhatsApp at 0302 7784296 for quick support.",
      },
      {
        "title": "Email",
        "icon": Icons.email,
        "content":
            "You can reach us at mawqif6@gmail.com for help or inquiries.",
      },
      {
        "title": "Website",
        "icon": Icons.language,
        "content":
            "Visit our website at www.mawqif.com to browse products and view your order history.",
      },
      {
        "title": "Facebook",
        "icon": Icons.facebook,
        "content":
            "Follow us on Facebook @mawqifapp for updates and promotions.",
      },
      {
        "title": "Twitter",
        "icon": Icons.travel_explore,
        "content":
            "Stay informed on Twitter @mawqif_support for real-time announcements.",
      },
      {
        "title": "Instagram",
        "icon": Icons.photo_camera,
        "content":
            "Discover our latest collections and user styles on Instagram @mawqif.official.",
      },
    ];

    return ListView(
      children:
          contacts.map((c) {
            return ExpansionTile(
              iconColor: Colors.brown.shade600,
              collapsedIconColor: Colors.brown.shade300,
              leading: Icon(
                c["icon"] as IconData,
                color: Colors.brown.shade700,
              ),
              title: Text(
                c["title"] as String,
                style: TextStyle(
                  color: Colors.brown.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 12),
                  child: Text(
                    c["content"] as String,
                    style: TextStyle(color: Colors.brown.shade600),
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Center"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown.shade800,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.brown.shade800,
          unselectedLabelColor: Colors.brown.shade400,
          indicatorColor: Colors.brown.shade600,
          tabs: const [Tab(text: "FAQ"), Tab(text: "Contact Us")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [buildFAQTab(), buildContactTab()],
      ),
    );
  }
}

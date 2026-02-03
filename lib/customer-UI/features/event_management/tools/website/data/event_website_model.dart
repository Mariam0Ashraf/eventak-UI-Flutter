class EventWebsite {
  final int id;
  final int eventId;
  final bool isPublished;
  final String slug;
  final String htmlUrl;
  final WebsiteDesign design;
  final WebsiteSEO seo;
  final WebsiteContent content;
  final WebsiteFeatures features;
  final List<WebsitePage> pages;

  EventWebsite({
    required this.id,
    required this.eventId,
    required this.isPublished,
    required this.slug,
    required this.htmlUrl,
    required this.design,
    required this.seo,
    required this.content,
    required this.features,
    required this.pages,
  });

  factory EventWebsite.fromJson(Map<String, dynamic> json) {
    return EventWebsite(
      id: json['id'],
      eventId: json['event_id'],
      isPublished: json['is_published'] ?? false,
      slug: json['slug'] ?? "",
      htmlUrl: json['public_url']?['html'] ?? "",
      design: WebsiteDesign.fromJson(json['design'] ?? {}),
      seo: WebsiteSEO.fromJson(json['seo'] ?? {}),
      content: WebsiteContent.fromJson(json['content'] ?? {}),
      features: WebsiteFeatures.fromJson(json['features'] ?? {}),
      pages: (json['pages'] as List? ?? [])
          .map((p) => WebsitePage.fromJson(p))
          .toList(),
    );
  }
}

class WebsiteDesign {
  final String template;
  final String primaryColor;
  final String secondaryColor;
  final String fontFamily;

  WebsiteDesign({required this.template, required this.primaryColor, required this.secondaryColor, required this.fontFamily});

  factory WebsiteDesign.fromJson(Map<String, dynamic> json) {
    return WebsiteDesign(
      template: json['template'] ?? 'classic',
      primaryColor: json['primary_color'] ?? '',
      secondaryColor: json['secondary_color'] ?? '',
      fontFamily: json['font_family'] ?? '',
    );
  }
}

class WebsiteSEO {
  final String metaTitle;
  final String metaDescription;

  WebsiteSEO({required this.metaTitle, required this.metaDescription});

  factory WebsiteSEO.fromJson(Map<String, dynamic> json) {
    return WebsiteSEO(
      metaTitle: json['meta_title'] ?? "",
      metaDescription: json['meta_description'] ?? "", 
    );
  }
}

class WebsiteContent {
  final String welcomeMessage;
  WebsiteContent({required this.welcomeMessage});
  factory WebsiteContent.fromJson(Map<String, dynamic> json) => 
      WebsiteContent(welcomeMessage: json['welcome_message'] ?? "");
}

class WebsiteFeatures {
  final bool showRsvp;
  final bool showTimeline;
  WebsiteFeatures({required this.showRsvp, required this.showTimeline});
  factory WebsiteFeatures.fromJson(Map<String, dynamic> json) => 
      WebsiteFeatures(showRsvp: json['show_rsvp'] ?? true, showTimeline: json['show_timeline'] ?? true);
}

class WebsitePage {
  final int id;
  final String title;
  final String slug;
  final bool isActive;
  WebsitePage({required this.id, required this.title, required this.slug, required this.isActive});
  factory WebsitePage.fromJson(Map<String, dynamic> json) => 
      WebsitePage(id: json['id'], title: json['title'] ?? "", slug: json['slug'] ?? "", isActive: json['is_active'] ?? false);
}
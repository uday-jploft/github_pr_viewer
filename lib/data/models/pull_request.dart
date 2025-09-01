import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PullRequest {
  final int id;
  final int number;
  final String title;
  final String? body;
  final String state;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User author;
  final String htmlUrl;
  final int additions;
  final int deletions;
  final int changedFiles;
  final bool draft;
  final List<Label> labels;

  PullRequest({
    required this.id,
    required this.number,
    required this.title,
    this.body,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.htmlUrl,
    this.additions = 0,
    this.deletions = 0,
    this.changedFiles = 0,
    this.draft = false,
    this.labels = const [],
  });

  factory PullRequest.fromJson(Map<String, dynamic> json) {
    return PullRequest(
      id: json['id'] as int,
      number: json['number'] as int,
      title: json['title'] as String,
      body: json['body'] as String?,
      state: json['state'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      author: User.fromJson(json['user'] as Map<String, dynamic>),
      htmlUrl: json['html_url'] as String,
      additions: json['additions'] as int? ?? 0,
      deletions: json['deletions'] as int? ?? 0,
      changedFiles: json['changed_files'] as int? ?? 0,
      draft: json['draft'] as bool? ?? false,
      labels: (json['labels'] as List<dynamic>?)
          ?.map((label) => Label.fromJson(label as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'body': body,
      'state': state,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': author.toJson(),
      'html_url': htmlUrl,
      'additions': additions,
      'deletions': deletions,
      'changed_files': changedFiles,
      'draft': draft,
      'labels': labels.map((label) => label.toJson()).toList(),
    };
  }

  // Helper methods for UI
  String get formattedCreatedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(createdAt);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String get shortDescription {
    if (body == null || body!.isEmpty) return 'No description provided';
    final words = body!.split(' ');
    if (words.length <= 20) return body!;
    return '${words.take(20).join(' ')}...';
  }

  int get totalChanges => additions + deletions;

  String get changesSummary {
    if (totalChanges == 0) return 'No changes';
    return '+$additions −$deletions';
  }
}

class User {
  final int id;
  final String login;
  final String avatarUrl;
  final String htmlUrl;
  final String type;

  User({
    required this.id,
    required this.login,
    required this.avatarUrl,
    required this.htmlUrl,
    required this.type,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
      htmlUrl: json['html_url'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'avatar_url': avatarUrl,
      'html_url': htmlUrl,
      'type': type,
    };
  }
}

class Label {
  final int id;
  final String name;
  final String color;
  final String? description;

  Label({
    required this.id,
    required this.name,
    required this.color,
    this.description,
  });

  factory Label.fromJson(Map<String, dynamic> json) {
    return Label(
      id: json['id'] as int,
      name: json['name'] as String,
      color: json['color'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'description': description,
    };
  }

  // Helper to convert hex color to Flutter Color
  Color get flutterColor {
    final hexColor = color.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}
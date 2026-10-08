class ParentStudent {
  final int linkId;
  final int organizationId;
  final String organizationCode;
  final String organizationName;
  final String studentId;
  final String relationship;

  final String name;
  final String classroom;
  final String cardId;
  final double balance;
  final String photoUrl;

  const ParentStudent({
    required this.linkId,
    required this.organizationId,
    required this.organizationCode,
    required this.organizationName,
    required this.studentId,
    required this.relationship,
    required this.name,
    required this.classroom,
    required this.cardId,
    required this.balance,
    required this.photoUrl,
  });

  factory ParentStudent.fromJson(Map<String, dynamic> json) {
    final student = Map<String, dynamic>.from(json['student'] ?? {});

    print('STUDENT PHOTO DEBUG: '
    'student_id=${student['userid']} '
    'photo_url=${student['photo_url']}');

    return ParentStudent(
      linkId: int.tryParse('${json['link_id'] ?? 0}') ?? 0,
      organizationId: int.tryParse('${json['organization_id'] ?? 0}') ?? 0,
      organizationCode: '${json['organization_code'] ?? ''}',
      organizationName: '${json['organization_name'] ?? ''}',
      studentId: '${json['student_id'] ?? student['userid'] ?? ''}',
      relationship: '${json['relationship'] ?? 'parent'}',
      name: '${student['name'] ?? ''}',
      classroom: '${student['classroom'] ?? ''}',
      cardId: '${student['cardid'] ?? ''}',
      balance: double.tryParse('${student['balance'] ?? 0}') ?? 0,
      photoUrl: '${student['photo_url'] ?? ''}',
    );
  }
}

import '../../domain/entities/question.dart';

/// 법령(과목) 카테고리. 콘텐츠 태그로 파생한다(JSON 미수정).
class LawCategory {
  final String id;
  final String name;
  final String? description;

  /// 목록 섹션 구분: '법령' | '기타' | '전체'.
  final String group;
  const LawCategory({
    required this.id,
    required this.name,
    this.description,
    required this.group,
  });
}

/// 유일 과목 id(= 콘텐츠 subjectId). '전체' 카테고리 id로도 쓴다.
const String kFireLawSubjectId = 'fire-law';

const String _p = '$kFireLawSubjectId::';

// 카테고리 id 상수.
const String catGibon = '${_p}law:gibon';
const String catYebang = '${_p}law:yebang';
const String catSisul = '${_p}law:sisul';
const String catGongsa = '${_p}law:gongsa';
const String catWiheom = '${_p}law:wiheom';
const String catJosa = '${_p}law:josa';
const String catCross = '${_p}cross';
const String catSimhwaEtc = '${_p}simhwa-etc';

/// 법령·기타 카테고리(표시 순서). '전체'는 [allCategory]로 별도.
const List<LawCategory> lawCategories = [
  LawCategory(id: catGibon, name: '소방기본법', group: '법령'),
  LawCategory(id: catYebang, name: '화재예방법', group: '법령'),
  LawCategory(id: catSisul, name: '소방시설법', group: '법령'),
  LawCategory(id: catGongsa, name: '소방공사업법', group: '법령'),
  LawCategory(id: catWiheom, name: '위험물안전관리법', group: '법령'),
  LawCategory(id: catJosa, name: '화재조사법', group: '법령'),
  LawCategory(
    id: catCross,
    name: '교차법령',
    description: '여러 법령을 묶은 문항',
    group: '기타',
  ),
  LawCategory(
    id: catSimhwaEtc,
    name: '심화 OX·계산',
    description: 'OX·계산 등 심화 문항',
    group: '기타',
  ),
];

/// 홈의 빠른/랜덤/오답/진척 분모 + 전체풀기용. 법령 목록과 별도.
const LawCategory allCategory =
    LawCategory(id: kFireLawSubjectId, name: '전체', group: '전체');

/// 법령 태그(정식명·축약형 모두) → 카테고리 id. 검수본은 정식명, 2026 AI 참고
/// 세트는 축약형을 써서 양쪽을 함께 매핑한다(검수본엔 축약형이 없어 충돌 없음).
const Map<String, String> _lawTagToCat = {
  '소방기본법': catGibon,
  '화재의 예방 및 안전관리에 관한 법률': catYebang,
  '화재예방법': catYebang,
  '소방시설 설치 및 관리에 관한 법률': catSisul,
  '소방시설 설치 및 관리에 관한 법': catSisul,
  '소방시설 설치 및 안전관리에 관한 법': catSisul,
  '소방시설의 설치 및 관리에 관한 법률': catSisul,
  '소방시설법': catSisul,
  '소방시설공사업법': catGongsa,
  '공사업법': catGongsa,
  '위험물안전관리법': catWiheom,
  '위험물법': catWiheom,
  '소방의 화재조사에 관한 법률': catJosa,
  '화재조사법': catJosa,
};

/// 문항 → 카테고리 id (정확히 1개). 교차법령 태그가 있거나 서로 다른 법령이
/// 2개 이상이면 교차, 정확히 1개면 그 법령, 없으면 심화 OX·계산.
String classifyCategoryId(Question q) {
  final tags = q.tags;
  final laws = <String>{};
  for (final t in tags) {
    final cat = _lawTagToCat[t];
    if (cat != null) laws.add(cat);
  }
  if (tags.contains('교차법령') || laws.length >= 2) return catCross;
  if (laws.length == 1) return laws.first;
  return catSimhwaEtc;
}

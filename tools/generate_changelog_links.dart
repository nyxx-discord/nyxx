import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:string_similarity/string_similarity.dart';

const org = 'nyxx-discord';
const repo = 'nyxx';
const url = 'https://github.com/$org/$repo';
const ua = '$repo +$url';

final token = Platform.environment['GITHUB_TOKEN']!;
final tokenAuthHeader = 'token $token';

final headers = {'Authorization': tokenAuthHeader, 'User-Agent': ua};

final linkRegexPattern = RegExp('${RegExp.escape(url)}\\/(?:pull|commit)\\/(?:[a-f0-9]{6,40}|\\d+)');
final mdRegexPattern =
    RegExp('\\(\\[`(?:[a-f0-9]{6,40}|#\\d+)`\\]\\(${linkRegexPattern.pattern}\\)\\)(?: - \\[`(?:[a-f0-9]{6,40}|#\\d+)`\\]\\(${linkRegexPattern.pattern}\\))?');

Future<void> main() async {
  final changelog = File('CHANGELOG.md');
  final lines = await changelog.readAsLines();
  final stringBuffer = StringBuffer();

  for (var line in lines) {
    if (line.startsWith('- ') && !mdRegexPattern.hasMatch(line)) {
      final (prNumber, commitHash) = await getPrNumber(line);
      final prLink = prNumber != null ? '([`#$prNumber`]($url/pull/$prNumber))' : '';
      final commitLink = commitHash != null ? '([`${commitHash.substring(0, 7)}`]($url/commit/$commitHash))' : '';
      if (prLink.isEmpty || commitLink.isEmpty) {
        print('Couldn\'t find any pull request or commit matching entry: ${line.substring(line.indexOf(':') + 2)}');
      }
      stringBuffer.writeln('$line${prLink.isNotEmpty ? ' $prLink - $commitLink' : commitLink.isNotEmpty ? ' $commitLink' : ''}');
    } else {
      stringBuffer.writeln(line);
    }
  }

  await changelog.writeAsString(stringBuffer.toString());

  print('CHANGELOG.md has been updated with the linked PRs and commits, make sure to double-check the links though.');
}

List<dynamic>? _cachedPulls;
String? nextPageUrl = 'https://api.github.com/repos/$org/$repo/pulls?state=closed&per_page=100';

Future<(String?, String?)> getPrNumber(String line) async {
  while (nextPageUrl != null) {
    final response = await http.get(
      Uri.parse(nextPageUrl!),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final pulls = jsonDecode(response.body) as List;
      (_cachedPulls ??= []).addAll(pulls);
      nextPageUrl = _extractNextPageUrl(response.headers['link']);
    } else {
      nextPageUrl = null;
    }
  }

  for (final pull in _cachedPulls!) {
    final (prNb, commit) = parsePrNumber(pull, line);

    if (prNb == null || commit == null) {
      continue;
    }

    return (prNb, commit);
  }

  return (null, null);
}

String? _extractNextPageUrl(String? linkHeader) {
  if (linkHeader == null) return null;

  final links = linkHeader.split(', ');
  for (final link in links) {
    final match = RegExp(r'<([^>]+)>; rel="next"').firstMatch(link);
    if (match != null) {
      return match.group(1);
    }
  }
  return null;
}

(String?, String?) parsePrNumber(dynamic data, String line) {
  if (data['title'] case final String title? when title.similarityTo(line) >= .6) {
    return (data['number'].toString(), data['merge_commit_sha'] as String);
  }

  return (null, null);
}

List<dynamic>? _cachedCommits;

Future<String?> getCommitHash(String line) async {
  if (_cachedCommits != null) {
    for (final commit in _cachedCommits!) {
      final result = parseCommitHash(commit, line);

      if (result == null) {
        continue;
      }

      return result;
    }
  } else {
    final response = await http.get(
      Uri.parse('https://api.github.com/repos/$org/$repo/commits'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final commits = jsonDecode(response.body) as List;
      _cachedCommits = commits;
      for (var commit in commits) {
        return parseCommitHash(commit, line);
      }
    }
  }

  return null;
}

String? parseCommitHash(dynamic data, String line) {
  if (data['commit']['message'] case final String message? when message.contains(line)) {
    return data['sha'] as String;
  }

  return null;
}

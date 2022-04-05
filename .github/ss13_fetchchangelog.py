import yaml, os, re, argparse
from github import Github, InputGitAuthor

opt = argparse.ArgumentParser()
opt.add_argument('ymlDir', help='The directory of YAML changelogs we will use.')

args = opt.parse_args()

prefixToActual = {
	'fix': 'bugfix',
	'sound': 'soundadd',
	'add': 'rscadd',
	'del': 'rscdel',
	'sprite': 'imageadd',
	'grammar': 'spellcheck',
	'code': 'code_imp',
}

def parse_pr_changelog(pr):
	yaml_object = {}
	changelog_match = re.search(r"🆑(.*)🆑", pr.body, re.S | re.M)
	if changelog_match is None:
		return
	lines = changelog_match.group(1).split('\n')
	entries = []
	for index, line in enumerate(lines):
		line = line.strip()
		if not line:
			continue
		if index == 0:
			author = None
			if not author or author == "John Titor":
				author = pr.user.name
				print("Author not set, substituting", author)
			yaml_object["author"] = author
			continue

		key = re.search(r"(.*):", line)
		if key is None:
			continue
		content = re.search(r":(.*)", line)
		if content is None:
			continue
		keyStr = key.group(1).strip()
		contentStr = content.group(1).strip()
		if keyStr in prefixToActual:
			keyStr = prefixToActual[keyStr]

		entry = "{}: {}".format(keyStr, contentStr)
		entries.append(entry)
	yaml_object["changes"] = entries
	return yaml_object

def main():
	g = Github()
	repo = g.get_repo(os.environ['REPO'])

	commit = repo.get_commit(os.environ["GITHUB_SHA"])
	pulls = commit.get_pulls()
	if not pulls.totalCount:
		print("Not a PR.")
		return
	pr = pulls[0]

	pr_data = parse_pr_changelog(pr)

	if pr_data is None: # no changelog
		print("No changelog provided.")
		return

	with open(os.path.join(args.ymlDir, "{}-{}.yml".format(os.environ["GITHUB_ACTOR"], os.environ["GITHUB_SHA"])), 'w') as file:
		yaml.dump(pr_data, file, default_flow_style=False)

if __name__ == '__main__':
	main()

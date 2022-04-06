import os, re
from github import Github

# Format - Key: Array[Label, [StringsToIgnore]]
changelogToPrefix = {
	'bugfix': ["Fix", ["fixed a few things"]],
	'qol': ["Quality Of Life", ["made something easier to use"]],
	'add': ["Feature", ["Added new mechanics or gameplay changes", "Added more things"]],
	'del': ["Removal", ["Removed old things"]],
	'tweak': ["Tweak", ["Tweaks to existing mechanics or gameplay"]],
	'spellcheck': ["Grammatical and Spelling Fixes", ["fixed a few typos"]],
	'balance': ["Balance", ["rebalanced something"]],
	'code': ["Code Improvement", ["changed some code"]],
	'refactor': ["Refactor", ["refactored some code"]],
	'config': ["Config", ["changed some config setting"]],
	'admin': ["Admin", ["messed with admin stuff"]],
	'server': ["Server", ["something server ops should know"]]
}

fileToPrefix = {
	'wav': 'Sound',
	'ogg': 'Sound',

	'js': 'UI',
	'tsx': 'UI',
	'ts': 'UI',
	'jsx': 'UI',
	'scss': 'UI',

	'dmi': "Sprites",
}

def get_labels(pr):
	labels = {}
	changelog_match = re.search(r"🆑(.*)🆑", pr.body, re.S | re.M)
	if changelog_match is None:
		return
	lines = changelog_match.group(1).split('\n')
	for line in lines:
		line = line.strip()
		if not line:
			continue

		contentSplit = line.split(":")

		key = contentSplit.pop(0).strip()
		content = ":".join(contentSplit).strip()

		if not key in changelogToPrefix:
			continue

		if content in changelogToPrefix[key][1]:
			continue

		labels[changelogToPrefix[key][0]] = True

	files = pr.get_files()
	for file in files:
		prefix = file.filename.split(".")[-1]
		if not prefix in fileToPrefix:
			continue
		labels[fileToPrefix[prefix]] = True
	return labels

def main():
	g = Github(os.environ["TOKEN"])
	repo = g.get_repo(os.environ['REPO'])

	commit = repo.get_commit(os.environ["GITHUB_SHA"])
	pulls = commit.get_pulls()
	if not pulls.totalCount:
		print("Not a PR.")
		return
	pr = pulls[0]

	labels = get_labels(pr)

	if labels is None: # no labels to add
		print("No labels to add.")
		return

	pr.add_to_labels(dict.keys(labels))


if __name__ == '__main__':
	main()

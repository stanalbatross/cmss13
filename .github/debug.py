import ss13_fetchchangelog
import yaml

class PR:
    user = "Test"
    body = """
    🆑 Watermelon's Cool Changelog
    add: This is a test
    balance: This is another test
    rscadd: An even better test
    del: Cool
    /🆑
    """

print(yaml.dump(ss13_fetchchangelog.parse_pr_changelog(PR)))

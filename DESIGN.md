### First Command

```shell
$ candidates user wifelette

*Here's everything you need to know about wifelette:*

**Their Basics**:

**Name**: Leah Silber
**Company**: Tilde.io
**Location**: Portland, OR
**Bio**: She's so awesome!
**Email**: leah@tilde.io
**Hireable**: Yes/No (Yes in Green, No in Red)

**Their Activity**:

**Joined GitHub**: September 9, 2008 (X years and Y months ago)
**Org Membership**: 4 organizations
**Public Repos**: 163 repos
**Followers**: 363 followers

**Lists you can dig into later**:
(ProTip: Command + click on any of these URLs in most Terminals to go directly to the link)

**Gists**: https://gist.github.com/search?o=desc&q=user%3Awifelette&s=stars
**Followers**: https://github.com/wifelette?tab=followers
**Repos**: https://github.com/wifelette?tab=repositories
**Starred Repos**: https://github.com/wifelette?tab=stars
**Who They Follow*: https://github.com/wifelette?tab=following

Next, type `candidate USERNAME help` to learn about how else this tool can help.
```

### Ideas for Other Commands

```
$ candidate wifelette languages

Of wifelette's 163 public repos, they break down as follows:

* 145 are Ruby (X percent)
* 2 are HTML (X percent)
* 4 are JavaScript (X percent)
* 1 is a Shell (X percent)
```

^ Color the language names? What if I don't know how many or which they'll be? Is there a way to use a `PASTEL.rand` kinda thing?

^ This may not be possible for rate limit reasons—so far the only way to find this data would be to get ALL the details on ALL their repos and then do a .length for the total number, annnd... so far no way for the type :p GitHub uses Linguist to do it themselves (https://help.github.com/en/articles/about-repository-languages) and so far there's nowhere exposed that they actually _store_ that info.

### Things to think about later

- Is it possible to reorder and/or add categories to how Thor presents all the commands when you type `help`?
- Some things, like email, won't work unless the person is authed. How to handle?
- if you accidentally type in just the `candidates user` instead of `candidates user username` a friendly and clear error message would be great
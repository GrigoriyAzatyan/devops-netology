# 1. Найдите полный хеш и комментарий коммита, хеш которого начинается на aefea.
`git show aefea`

**Полный хэш: aefead2207ef7e2aa5dc81a34aedf0cad4c32545**

**Комментарий:     Update CHANGELOG.md**

# 2. Какому тегу соответствует коммит 85024d3?
`git show 85024d3`

commit 85024d3100126de36331c6982bfaac02cdab9e76 (tag: v0.12.23)

**Тег: v0.12.23**

# 3. Сколько родителей у коммита b8d720? Напишите их хеши.
Два родителя: 

56cd7859e05c36c06b56d013b55a252d0bb7e158

9ea88f22fc6269854151c571162c5bcf958bee2b


# 4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами v0.12.23 и v0.12.24.
`git log v0.12.23..v0.12.24`


* commit 33ff1c03bb960b332be3af2e333462dde88b279e (tag: v0.12.24)
    
	*v0.12.24*

* commit b14b74c4939dcab573326f4e3ee2a62e23e12f89
    
	*[Website] vmc provider links*

* commit 3f235065b9347a758efadc92295b540ee0a5e26e

    *Update CHANGELOG.md*

* commit 6ae64e247b332925b872447e9ce869657281c2bf

    *registry: Fix panic when server is unreachable*

    *Non-HTTP errors previously resulted in a panic due to dereferencing the
    resp pointer while it was nil, as part of rendering the error message.
    This * commit changes the error message formatting to cope with a nil
    response, and extends test coverage.*

   *Fixes #24384*

* commit 5c619ca1baf2e21a155fcdb4c264cc9e24a2a353

    *website: Remove links to the getting started guide's old location

    *Since these links were in the soon-to-be-deprecated 0.11 language section, I
    think we can just remove them without needing to find an equivalent link.*

* commit 06275647e2b53d97d4f0a19a0fec11f6d69820b5

    *Update CHANGELOG.md*

* commit d5f9411f5108260320064349b757f55c09bc4b80

    *command: Fix bug when using terraform login on Windows*

* commit 4b6d06cc5dcb78af637bbb19c198faff37a066ed

    *Update CHANGELOG.md*

* commit dd01a35078f040ca984cdd349f18d0b67e486c35

    *Update CHANGELOG.md*

* commit 225466bc3e5f35baa5d07197bbc079345b77525e

    *Cleanup after v0.12.23 release*


# 5. Найдите коммит, в котором была создана функция func providerSource, ее определение в коде выглядит так func providerSource(...) (вместо троеточего перечислены аргументы).
`git log -S 'func providerSource'`

Получили:

`commit 5af1e6234ab6da412fb8637393c5a17a1b293663`

`Date:   Tue Apr 21 16:28:59 2020 -0700`



`commit 8c928e83589d90a031f811fae52a81be7153e82f`

`Date:   Thu Apr 2 18:04:39 2020 -0700`

Посмотрим более ранний из них:

`git show 8c928e8 | grep "func providerSource"`

+func providerSource(services *disco.Disco) getproviders.Source {

**Нашли: это коммит 8c928e83589d90a031f811fae52a81be7153e82f**

# 6. Найдите все коммиты, в которых была изменена функция globalPluginDirs.

`git log -S 'globalPluginDirs'`


Получили 3 коммита:
`commit 35a058fb3ddfae9cfee0b3893822c9a95b920f4c`

`Date:   Thu Oct 19 17:40:20 2017 -0700`


`commit c0b17610965450a89598da491ce9b6b5cbd6393f`

`Date:   Mon Jun 12 15:04:40 2017 -0400`

  
`commit 8364383c359a6b738a436d1b7745ccdce178df47`

`Date:   Thu Apr 13 18:05:58 2017 -0700`


Соответственно, в наиболее раннем из них функция создана, а в следующих отредактирована:

**c0b17610965450a89598da491ce9b6b5cbd6393f**

**35a058fb3ddfae9cfee0b3893822c9a95b920f4c**

# 7. Кто автор функции synchronizedWriters?

`git log -S "synchronizedWriters"`

Наиболее ранний коммит:

commit 5ac311e2a91e381e2f52234668b49ba670aa0fe5

Author: Martin Atkins <mart@degeneration.co.uk>

Посмотрим, в каких файлах эта функция упоминается:
`git grep --break -n "synchronizedWriters" 5ac311e2a91e381e2f52234668b49ba670aa0fe5`

	5ac311e2a91e381e2f52234668b49ba670aa0fe5:main.go:267:           wrapped := synchronizedWriters(stdout, stderr)

	5ac311e2a91e381e2f52234668b49ba670aa0fe5:synchronized_writers.go:13:// synchronizedWriters takes a set of writers and returns wrappers that ensure

	5ac311e2a91e381e2f52234668b49ba670aa0fe5:synchronized_writers.go:15:func synchronizedWriters(targets ...io.Writer) []io.Writer {

`git checkout 5ac311e2`

`git blame -C -L 13,15 ./synchronized_writers.go`

	5ac311e2a9 (Martin Atkins 2017-05-03 16:25:41 -0700 15) func synchronizedWriters(targets ...io.Writer) []io.Writer {

**Автор: Martin Atkins**



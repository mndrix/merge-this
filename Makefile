bzr:
	env VCS=bzr prove -lr t

darcs:
	env VCS=darcs prove -lr t

git:
	env VCS=git prove -lr t

hg:
	env VCS=hg prove -lr t
svn:
	env VCS=svn prove -lr t


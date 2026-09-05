.PHONY: deps
deps:
	brew install stylua lua-language-server

.PHONY: fmt
fmt:
	stylua --indent-type Spaces --indent-width 2 init.lua

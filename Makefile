.PHONY: deps
deps:
	brew install stylua

.PHONY: fmt
fmt:
	stylua --indent-type Spaces --indent-width 2 init.lua

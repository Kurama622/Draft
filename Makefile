# 将Markdown文件转换为HTML，并将生成的HTML文件放在指定路径下

# 定义pandoc选项
PANDOC_OPTIONS=--embed-resources -c pandoc.css --include-before-body=navbar.html --toc --lua-filter=toc-css.lua --standalone 

# 指定输出目录
OUTPUT_DIR=site

# 找到所有Markdown文件
# MARKDOWN_FILES=$(shell find . -name '*.md')
# 找到所有有更改的Markdown文件，包括新增文件
MARKDOWN_FILES=$(shell git diff --name-only --diff-filter=ACMRTUXB HEAD | grep md)
# 将Markdown文件路径替换为HTML文件路径，并设置输出目录
HTML_FILES=$(patsubst %.md,$(OUTPUT_DIR)/%.html,$(MARKDOWN_FILES))

# 默认目标：生成所有HTML文件
all: $(HTML_FILES)

# 生成HTML文件
$(OUTPUT_DIR)/%.html: %.md
	mkdir -p $(dir $@)
	pandoc --embed-resources -c pandoc.css --include-before-body=navbar.html --toc --lua-filter=toc-css.lua --standalone --metadata toc-title=$(shell basename $(dir $<)) $< -o $(dir $@)/index.html

$(OUTPUT_DIR)/README.html: README.md
	mkdir -p $(OUTPUT_DIR)
	pandoc --embed-resources -c pandoc.css --include-before-body=navbar.html --toc --lua-filter=toc-css.lua --standalone --metadata toc-title="Draft" $< -o $(dir $@)/index.html

$(OUTPUT_DIR)/./README.html: README.md
	mkdir -p $(OUTPUT_DIR)
	pandoc --embed-resources -c pandoc.css --include-before-body=navbar.html --toc --lua-filter=toc-css.lua --standalone --metadata toc-title="Draft" $< -o $(dir $@)/index.html

# 删除所有HTML文件
clean:
	rm -rf $(OUTPUT_DIR)


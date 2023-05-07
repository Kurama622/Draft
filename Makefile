# 将Markdown文件转换为HTML，并将生成的HTML文件放在指定路径下

# 定义pandoc选项
PANDOC_OPTIONS=--embed-resources -c pandoc.css --include-before-body=navbar.html --toc --lua-filter=toc-css.lua --standalone 

# 指定输出目录
OUTPUT_DIR=site

# 找到所有Markdown文件
MARKDOWN_FILES=$(shell find . -name '*.md')

# 将Markdown文件路径替换为HTML文件路径，并设置输出目录
HTML_FILES=$(patsubst %.md,$(OUTPUT_DIR)/%.html,$(MARKDOWN_FILES))

# 默认目标：生成所有HTML文件
all: $(HTML_FILES)

# 生成HTML文件
$(OUTPUT_DIR)/%.html: %.md
	mkdir -p $(dir $@)
	# directory_name=$(basename $(dir $$@))
	directory_name=$(shell basename $(dir $<))
	# $(info $(HTML_FILES))
	pandoc --embed-resources -c pandoc.css --include-before-body=navbar.html --toc --lua-filter=toc-css.lua --standalone --metadata toc-title=$(shell basename $(dir $<)) $< -o $@

all:
	mv $(OUTPUT_DIR)/README.html $(OUTPUT_DIR)/index.html
# 删除所有HTML文件
clean:
	rm -rf $(OUTPUT_DIR)


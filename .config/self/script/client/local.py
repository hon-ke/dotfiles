import re
import yaml
from pathlib import Path
from typing import List, Dict, Any, Optional, Tuple
from dataclasses import dataclass, field, asdict
import urllib.parse

class SimpleLog:
    
    def __init__(self, detail_color="\033[90m"):  # 默认为灰色
        self.detail_color = detail_color

    def info(self, *args, **kwargs):
        """信息级别日志 - 蓝色"""
        self._log("\033[94m[-]\033[0m", *args, **kwargs)

    def success(self, *args, **kwargs):
        """成功级别日志 - 绿色"""
        self._log("\033[92m[+]\033[0m", *args, **kwargs)

    def debug(self, *args, **kwargs):
        """调试级别日志 - 白色"""
        self._log("\033[97m[-]\033[0m", *args, **kwargs)

    def error(self, *args, **kwargs):
        """错误级别日志 - 红色"""
        self._log("\033[91m[!]", *args, **kwargs)

    def warning(self, *args, **kwargs):
        """警告级别日志 - 黄色"""
        self._log("\033[93m[?]\033[0m", *args, **kwargs)

    def _log(self, symbol, *args, **kwargs):
        """
        基础日志方法

        Args:
            symbol: 日志符号和颜色
            *args: 位置参数
            **kwargs: 关键字参数
        """
        # 打印位置参数
        if args:
            print(f"{symbol}", *args)

        # 打印关键字参数
        if kwargs:
            ignore_list = kwargs.get("ignore_list",["content","excerpt","description","attach","files"])
            show_ignore = kwargs.get("show_ignore",False)
            max_key_length = max(len(str(key)) for key in kwargs.keys())

            for key, value in kwargs.items():
                if not show_ignore and key in ignore_list:
                    continue
                # 格式化值
                if isinstance(value, (dict, list, tuple, set)):
                    formatted_value = str(value)
                elif isinstance(value, str):
                    formatted_value = f"'{value}'"
                else:
                    formatted_value = str(value)

                # 使用配置的颜色
                terminal_context = f"{self.detail_color}│ {str(key):>{max_key_length}} : {formatted_value}\033[0m"
                print(terminal_context)


# 创建实例时可以选择颜色
# log = SimpleLog(detail_color="\033[36m")  # 青色
# log = SimpleLog(detail_color="\033[33m")  # 黄色
# log = SimpleLog(detail_color="\033[35m")  # 紫色
log = SimpleLog()  # 默认灰色

@dataclass
class Post:
    """文章数据结构"""
    title: str
    content: str
    tag: str = ""
    category: str = ""
    excerpt: str = ""
    cover: str = ""
    is_top: bool = False
    is_locked: bool = False
    attach: List[Dict[str, str]] = field(default_factory=list)
    file_path: str = ""

@dataclass
class Page:
    """页面数据结构"""
    title: str
    content: str
    description: str = ""
    icon: str = ""
    is_active: bool = True
    order: int = 10
    attach: List[Dict[str, str]] = field(default_factory=list)
    file_path: str = ""



class DocsScanner:
    """本地文档管理器"""
    def __init__(self, docs_root: str = "docs", ignore_list: List = None):
        self.docs_root = Path(docs_root)
        self.supported_extensions = {'.md', '.markdown',".txt"}
        
        # 设置忽略列表
        if ignore_list is None:
            self.ignore_list = ["文章模板.md", "页面模板.md","草稿"]
        else:
            self.ignore_list = ignore_list

    def _should_ignore_file(self, file_path: Path) -> bool:
        """
        检查文件是否应该被忽略
        
        Args:
            file_path: 文件路径
            
        Returns:
            bool: 如果应该忽略返回True，否则返回False
        """
        # 检查文件名是否在忽略列表中
        if file_path.name in self.ignore_list:
            return True
        
        # 检查文件路径是否包含忽略列表中的任何部分
        for ignore_pattern in self.ignore_list:
            if ignore_pattern in str(file_path):
                return True
        
        return False

    def parse_frontmatter(self, content: str) -> Tuple[Dict[str, Any], str]:
        """解析 Front Matter 元数据"""
        metadata = {}
        pure_content = content

        frontmatter_pattern = r'^---\s*\n(.*?)\n---\s*\n(.*)$'
        match = re.match(frontmatter_pattern, content, re.DOTALL)

        if match:
            try:
                frontmatter_content = match.group(1)
                pure_content = match.group(2)
                metadata = yaml.safe_load(frontmatter_content) or {}
            except (yaml.YAMLError, Exception):
                pass

        return metadata, pure_content

    def extract_cover_from_content(self, content: str) -> str:
        """从内容中提取第一个图片作为封面"""
        img_pattern = r'!\[.*?\]\((.*?)\)'
        matches = re.findall(img_pattern, content)
        if matches:
            return matches[0].replace("file://", "")

        html_img_pattern = r'<img.*?src="(.*?)".*?>'
        html_matches = re.findall(html_img_pattern, content)
        return html_matches[0] if html_matches else ""

    def generate_excerpt(self, content: str, length: int = 150) -> str:
        """生成摘要"""
        clean_content = re.sub(r'[#*`\[\]!]', '', content)
        clean_content = re.sub(r'\s+', ' ', clean_content).strip()
        
        if len(clean_content) <= length:
            return clean_content
            
        return clean_content[:length] + "..."

    def get_category_and_tag_from_path(self, file_path: Path) -> Tuple[str, str]:
        """根据文件路径确定分类和标签"""
        try:
            relative_path = file_path.relative_to(self.docs_root)
            parts = relative_path.parts

            # 如果文件在根目录，则没有分类和标签（是页面）
            if len(parts) == 1:
                return "", ""
            
            # 第一个子目录作为分类
            category = parts[0]
            
            # 第二个子目录作为标签
            tag = parts[1] if len(parts) > 2 else ""
            
            return category, tag
        except ValueError:
            # 如果文件不在 docs_root 下，返回空字符串
            return "", ""

    def extract_title(self, metadata: Dict[str, Any], content: str, file_path: Path) -> str:
        """获取文章标题（按优先级）"""
        # 1. 元数据中的 title
        if 'title' in metadata and metadata['title']:
            return metadata['title']
            
        # 2. 内容中的一级标题
        h1_pattern = r'^#\s+(.+)$'
        match = re.search(h1_pattern, content, re.MULTILINE)
        if match:
            return match.group(1).strip()
            
        # 3. 文件名
        return Path(file_path.name).stem

    def _is_external_url(self, url: str) -> bool:
        """检查是否为外部URL"""
        external_prefixes = ('http://', 'https://', '//', 'ftp://', 'mailto:', 'tel:')
        return url.startswith(external_prefixes)

    def _clean_url(self, url: str) -> str:
        """清理URL，去除查询参数和锚点"""
        # 移除URL编码（如果需要）
        try:
            url = urllib.parse.unquote(url)
        except:
            pass
        
        # 分割URL，去除查询参数和锚点
        parts = urllib.parse.urlparse(url)
        clean_path = parts.path
        
        return clean_path

    def _resolve_file_path(self, file_path_str: str, parent_dir: Path) -> Path:
        """解析文件路径，处理各种情况"""
        # 清理URL
        clean_path = self._clean_url(file_path_str)
        
        # 处理以 / 开头的绝对路径
        if clean_path.startswith('/'):
            return Path(clean_path)
        
        # 处理相对路径
        return (parent_dir / clean_path).resolve()

    def _extract_markdown_attachments(self, content: str, parent_dir: Path) -> List[Dict[str, str]]:
        """提取Markdown格式的附件"""
        attachments = []
        found_paths = set()
        
        # 改进的Markdown图片正则表达式，正确处理带标题的情况
        # 格式: ![alt](path) 或 ![alt](path "title")
        img_pattern = r'!\[([^\]]*)\]\(\s*([^)\s]+)(?:\s+[^)]*)?\s*\)'
        matches = re.findall(img_pattern, content)
        
        for alt_text, file_path_str in matches:
            # 清理路径，去除可能的引号
            file_path_str = file_path_str.strip('"\'')
            
            if self._is_external_url(file_path_str) or file_path_str in found_paths:
                continue
                
            abs_path = self._resolve_file_path(file_path_str, parent_dir)
            
            if abs_path.exists() and abs_path.is_file():
                attachments.append({
                    "origin": file_path_str,
                    "absolute": str(abs_path),
                    "filename": abs_path.name,
                    "type": "image",
                    "alt_text": alt_text
                })
                found_paths.add(file_path_str)
                
        return attachments

    def _extract_html_attachments(self, content: str, parent_dir: Path) -> List[Dict[str, str]]:
        """提取HTML格式的附件"""
        attachments = []
        found_paths = set()
        
        # HTML图片: <img src="path" alt="alt">
        html_img_pattern = r'<img[^>]*src=["\']([^"\']+)["\'][^>]*>'
        matches = re.findall(html_img_pattern, content, re.IGNORECASE)
        
        for file_path_str in matches:
            if self._is_external_url(file_path_str) or file_path_str in found_paths:
                continue
                
            abs_path = self._resolve_file_path(file_path_str, parent_dir)
            
            if abs_path.exists() and abs_path.is_file():
                attachments.append({
                    "origin": file_path_str,
                    "absolute": str(abs_path),
                    "filename": abs_path.name,
                    "type": "image"
                })
                found_paths.add(file_path_str)
                
        return attachments

    def _extract_file_links(self, content: str, parent_dir: Path, exclude_paths: set) -> List[Dict[str, str]]:
        """提取文件链接附件"""
        attachments = []
        found_paths = set()
        
        # 改进的Markdown链接正则表达式，正确处理带标题的情况
        # 格式: [text](path) 或 [text](path "title")
        link_pattern = r'\[([^\]]+)\]\(\s*([^)\s]+)(?:\s+[^)]*)?\s*\)'
        matches = re.findall(link_pattern, content)
        
        for link_text, file_path_str in matches:
            # 清理路径，去除可能的引号
            file_path_str = file_path_str.strip('"\'')
            
            # 跳过已经找到的路径和外部URL
            if (self._is_external_url(file_path_str) or 
                file_path_str in found_paths or 
                file_path_str in exclude_paths):
                continue
                
            abs_path = self._resolve_file_path(file_path_str, parent_dir)
            
            if abs_path.exists() and abs_path.is_file():
                attachments.append({
                    "origin": file_path_str,
                    "absolute": str(abs_path),
                    "filename": abs_path.name,
                    "type": "file",
                    "link_text": link_text
                })
                found_paths.add(file_path_str)
                
        return attachments

    def _extract_direct_urls(self, content: str, parent_dir: Path, exclude_paths: set) -> List[Dict[str, str]]:
        """提取直接URL（非链接形式的文件路径）"""
        attachments = []
        found_paths = set()
        
        # 匹配看起来像文件路径的字符串
        # 这个正则表达式匹配包含常见文件扩展名的路径
        file_pattern = r'\b(?:[\w/-]+\.(?:jpg|jpeg|png|gif|webp|bmp|pdf|doc|docx|txt|zip|rar|mp4|avi|mov))\b'
        matches = re.findall(file_pattern, content, re.IGNORECASE)
        
        for file_path_str in matches:
            # 跳过已经找到的路径和外部URL
            if (self._is_external_url(file_path_str) or 
                file_path_str in found_paths or 
                file_path_str in exclude_paths):
                continue
                
            abs_path = self._resolve_file_path(file_path_str, parent_dir)
            
            if abs_path.exists() and abs_path.is_file():
                attachments.append({
                    "origin": file_path_str,
                    "absolute": str(abs_path),
                    "filename": abs_path.name,
                    "type": "direct"
                })
                found_paths.add(file_path_str)
                
        return attachments

    def find_attachments(self, file_path: Path) -> List[Dict[str, str]]:
        """查找文章中的所有附件"""
        attachments = []
        
        try:
            content = file_path.read_text(encoding='utf-8')
            parent_dir = file_path.parent
            
            # 按优先级查找不同类型的附件
            md_attachments = self._extract_markdown_attachments(content, parent_dir)
            attachments.extend(md_attachments)
            
            html_attachments = self._extract_html_attachments(content, parent_dir)
            attachments.extend(html_attachments)
            
            # 排除已经找到的路径
            found_paths = {attach["origin"] for attach in attachments}
            
            file_links = self._extract_file_links(content, parent_dir, found_paths)
            attachments.extend(file_links)
            
            # 更新已找到的路径
            found_paths.update({attach["origin"] for attach in file_links})
            
            direct_urls = self._extract_direct_urls(content, parent_dir, found_paths)
            attachments.extend(direct_urls)
                        
        except Exception as e:
            print(f"查找附件时出错: {e}")
            
        return attachments

    def get_tag_from_metadata(self, metadata: Dict[str, Any], tag_from_path: str) -> str:
        """从元数据中获取标签，优先使用元数据中的标签"""
        # 尝试从 tag 字段获取
        tag_value = metadata.get('tag')
        if tag_value:
            if isinstance(tag_value, list) and tag_value:
                return str(tag_value[0])
            return str(tag_value)

        # 尝试从 tags 字段获取
        tags_value = metadata.get('tags')
        if tags_value:
            if isinstance(tags_value, list) and tags_value:
                return str(tags_value[0])
            elif tags_value:
                return str(tags_value)

        # 如果元数据中没有标签，使用路径中的标签
        return tag_from_path

    def scan_post_file(self, file_path: Path) -> Optional[Post]:
        """扫描文章文件"""
        if file_path.suffix.lower() not in self.supported_extensions:
            return None

        try:
            content = file_path.read_text(encoding='utf-8')
            metadata, pure_content = self.parse_frontmatter(content)
            category, tag_from_path = self.get_category_and_tag_from_path(file_path)

            # 如果文件在根目录，不应该被识别为文章
            if not category:
                return None

            # 构建文章对象
            title = self.extract_title(metadata, pure_content, file_path)
            tag = self.get_tag_from_metadata(metadata, tag_from_path)
            excerpt = metadata.get('excerpt', self.generate_excerpt(pure_content))
            
            # 封面
            cover_from_metadata = metadata.get('cover')
            cover = cover_from_metadata if cover_from_metadata else self.extract_cover_from_content(pure_content)
            
            # 其他属性
            is_top = metadata.get('is_top', False)
            is_locked = metadata.get('is_locked', False)
            attachments = self.find_attachments(file_path)

            return Post(
                title=title,
                content=pure_content,
                tag=tag,
                category=category,
                excerpt=excerpt,
                cover=cover,
                is_top=is_top,
                is_locked=is_locked,
                attach=attachments,
                file_path=str(file_path)
            )

        except Exception as e:
            print(f"扫描文章文件出错: {file_path}, 错误: {e}")
            return None

    def scan_page_file(self, file_path: Path) -> Optional[Page]:
        """扫描页面文件"""
        if file_path.suffix.lower() not in self.supported_extensions:
            return None

        try:
            content = file_path.read_text(encoding='utf-8')
            metadata, pure_content = self.parse_frontmatter(content)

            # 构建页面对象
            name = metadata.get('name', Path(file_path.name).stem)
            title = self.extract_title(metadata, pure_content, file_path)
            description = metadata.get('description', self.generate_excerpt(pure_content))
            icon = metadata.get('icon', "")
            is_active = metadata.get('is_active', True)
            order = metadata.get('order', 10)
            
            # 页面也添加附件功能
            attachments = self.find_attachments(file_path)

            return Page(
                title=title,
                content=pure_content,
                description=description,
                icon=icon,
                is_active=is_active,
                order=order,
                attach=attachments,
                file_path=str(file_path)
            )

        except Exception as e:
            print(f"扫描页面文件出错: {file_path}, 错误: {e}")
            return None

    def scan_directory(self) -> Tuple[List[Post], List[Page]]:
        """扫描目录，返回文章和页面"""
        posts = []
        pages = []

        if not self.docs_root.exists():
            print(f"文档目录不存在: {self.docs_root}")
            return posts, pages

        
        # 扫描所有文件
        for file_path in self.docs_root.rglob("*"):
            # 检查是否应该忽略该文件
            if self._should_ignore_file(file_path):
                continue

            if file_path.is_file() and file_path.suffix.lower() in self.supported_extensions:
                # 检查文件是否在根目录
                try:
                    relative_path = file_path.relative_to(self.docs_root)
                    # 如果文件在根目录，则是页面
                    if len(relative_path.parts) == 1:
                        page = self.scan_page_file(file_path)
                        if page:
                            pages.append(page)
                    else:
                        # 否则是文章
                        post = self.scan_post_file(file_path)
                        if post:
                            posts.append(post)
                except ValueError:
                    # 文件不在 docs_root 下，跳过
                    continue

        return posts, pages

    def get_all_posts(self) -> List[Post]:
        """获取所有文章"""
        posts, _ = self.scan_directory()
        return posts

    def get_all_pages(self) -> List[Page]:
        """获取所有页面"""
        _, pages = self.scan_directory()
        return pages

    def get_posts_summary(self, posts: List[Post]) -> List[Dict[str, Any]]:
        """获取文章摘要信息"""
        return [
            {
                "title": post.title,
                "category": post.category,
                "tag": post.tag,
                "file_path": post.file_path,
                "attachment_count": len(post.attach)
            }
            for post in posts
        ]

    def get_pages_summary(self, pages: List[Page]) -> List[Dict[str, Any]]:
        """获取页面摘要信息"""
        return [
            {
                "title": page.title,
                "description": page.description,
                "file_path": page.file_path,
                "attachment_count": len(page.attach)
            }
            for page in pages
        ]

class DocsMaker:

    def __init__(self, docs_dir):
        self.docs_dir = Path(docs_dir)
        self.docs_dir.mkdir(parents=True, exist_ok=True)

    def example_dir(self):
        """创建示例目录"""
        example_list = ["笔记", "测试"]
        for x in example_list:
            path = self.docs_dir / x
            path.mkdir(exist_ok=True)
    
    def example_data(self):
        """返回示例数据"""
        return [
            # 类型, 文件名, 文件内容
            ("page", "关于.md", "## 关于博客\n\n这是我的个人博客，分享技术文章和生活感悟。\n\n### 博客特点\n\n- 技术文章分享\n- 学习笔记记录\n- 项目经验总结\n\n欢迎交流讨论！"),
            ("page", "友链.md", "# 友情链接\n\n## 我的博客信息\n\n**博客名称**：红客路上  \n**博客网址**：http://hon-ker.cn  \n**博客描述**：荣耀之前是长夜的等待  \n**头像链接**：http://hon-ker.cn/static/avatar.jpg  \n**联系邮箱**：clay@hon-ker.cn\n\n---\n\n## 优秀博客推荐\n\n### 技术类博客\n\n-  [TechStack](https://techstack.example.com)  - 专注于全栈开发技术分享\n- [算法之美](https://algo.example.com) - 算法学习与竞赛经验\n- [DevOps实践](https://devops.example.com) - DevOps工具链与最佳实践\n\n### 设计类博客\n\n- [UI设计派](https://ui.example.com) - UI/UX设计理念与案例\n- [创意视觉](https://creative.example.com) - 平面设计与视觉艺术\n\n### 生活类博客\n\n- [旅行者的笔记](https://travel.example.com) - 环球旅行见闻与攻略\n- [阅读时光](https://reading.example.com) - 读书笔记与文学评论\n\n---\n\n## 友链交换说明\n\n### 基本要求\n\n1. **内容质量**：网站内容原创度高，有价值且定期更新\n2. **主题相关**：优先考虑技术、编程、设计、创业等相关主题\n3. **网站稳定**：网站可正常访问，无大量广告或弹窗\n4. **合法合规**：内容符合法律法规，不涉及敏感话题\n\n### 申请方式\n\n请按照以下格式在您的网站添加本站链接后，通过邮件联系我：\n\n**站点名称**：Clay的技术博客  \n**站点地址**：https://blog.clay.com  \n**站点描述**：分享编程技术、开发经验和生活思考\n\n然后发送邮件至 contact@clay.com，附上您的：\n- 网站名称\n- 网站地址\n- 网站描述\n- logo/头像链接（可选）\n\n### 注意事项\n\n- 我会在1-3个工作日内审核并添加符合要求的友链\n- 如链接失效或内容不符合要求，我保留移除链接的权利\n- 欢迎技术交流与合作，共同进步！\n\n---\n\n*感谢所有支持本站的朋友，让我们一起创造更有价值的互联网内容！*"),
            ("post", "测试/关于cli的其相关说明.md", "# CLI 工具使用说明\n\n## 功能概述\n\n这是一个用于博客管理的命令行工具，支持文章的发布、更新和同步。\n\n### 主要命令\n\n```bash\npython main.py push      # 推送本地文章\npython main.py pull      # 拉取远程文章\npython main.py backup    # 备份数据\n```\n\n### 配置说明\n\n工具使用 YAML 配置文件，支持自定义服务器地址和 API 密钥。"),
            ("post", "笔记/笔记的名字可以随意.md", "# 任务清单\n\n## 待办事项\n- [ ] 编写项目文档\n- [ ] 修复 Bug #123\n- [ ] 代码审查\n- [ ] 学习新技术\n- [ ] 整理工作笔记\n\n## 进行中\n- [x] 设计数据库架构\n- [ ] 开发用户模块\n- [ ] 编写测试用例\n\n## 已完成\n- [x] 项目需求分析\n- [x] 技术选型\n- [x] 环境搭建\n\n---\n**进度**：3/8 已完成 (37.5%)"),
        ]
    
    def meta(self):
        """返回元数据模板"""
        return {
            "post": {
                'title': '', 
                'category': '', 
                'tag': '', 
                'excerpt': '随便写点什么当摘要...', 
                'cover': '', 
                'is_top': False, 
                'is_locked': False
            },
            "page": {
                'title': '', 
                'description': '', 
                'icon': 'czs-block-l', 
                'is_active': True, 
                'order': 100
            }
        }


    def format_meta(self, meta: Dict) -> str:
        """
        将元数据字典格式化为 Markdown 文件的 YAML front matter
        
        Args:
            meta: 元数据字典
            
        Returns:
            格式化的 YAML front matter 字符串
        """
        # 将元数据转换为 YAML 格式
        yaml_content = yaml.dump(
            meta, 
            default_flow_style=False, 
            allow_unicode=True, 
            sort_keys=False,
            indent=2
        )
        
        # 构建完整的 front matter
        front_matter = f"---\n{yaml_content}---\n"
        return front_matter

    def write_file(self, filename, content):
        """写入文件"""
        try:
            with open(filename, "w", encoding="utf-8") as file:
                file.write(content)
        except Exception as e:
            raise e

    def example_maker(self):
        """创建示例文件"""
        # 首先创建目录
        self.example_dir()
        meta = self.meta()

        for file_type, filename, content in self.example_data():
            
            file_path = self.docs_dir / filename
            
 
            # 从文件名提取标题
            title = Path(filename).stem  # 获取文件名（不带扩展名）
            
            # 根据文件类型准备元数据
            file_meta = meta[file_type].copy()
            file_meta['title'] = title
            
            # 格式化元数据
            meta_data = self.format_meta(file_meta)
            
            # 组合完整内容
            full_content = meta_data + "\n" + content
            
            # 确保目录存在并写入文件
            file_path.parent.mkdir(parents=True, exist_ok=True)
            self.write_file(file_path, full_content)

    def template_maker(self):
        # 获取纯净的模板
        meta = self.meta()
        template = [("post","文章模板.md"),("page","页面模板.md")]
        for type,file in template:
            file_path =  self.docs_dir / file
            file_path.parent.mkdir(parents=True, exist_ok=True)
            file_meta = meta[type].copy()
            log.error(**file_meta)

            meta_data = self.format_meta(file_meta)
            self.write_file(file_path, meta_data+"\n")
            

            


# 使用示例
if __name__ == "__main__":
    template = DocsMaker("docs")
    template.template_maker()
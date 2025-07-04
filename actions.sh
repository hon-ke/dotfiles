echo  -e "\n======================================"

echo  -en  "[-] 基础设置及启动服务 ..."
sudo systemctl enable v2raya.service>/dev/null 2>&1 &&
sudo systemctl start v2raya.service>/dev/null 2>&1 &&
sudo chown -R clay:clay /data /tools /opt>/dev/null 2>&1  && echo -e "成功" || echo -e "失败"

echo  -ne  "[-] 安装nodejs ... "
nvm install v22.16.0>/dev/null 2>&1 &&
npm config set registry https://registry.npmmirror.com>/dev/null 2>&1 &&
npm install -g yarn && echo -e "成功" || echo -e "失败"

echo  -en  "[-] nvim配置 ... "
# 安装vim插件管理 plug
git clone https://github.com/junegunn/vim-plug.git /tmp/vim-plug>/dev/null 2>&1 &&
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/" &&
cp -rf /tmp/vim-plug/plug.vim "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/" &&
nvim --headless -c 'PlugInstall' -c 'qa' >/dev/null 2>&1 &&
nvim --headless -c 'CocInstall -sync coc-json coc-pyright coc-yaml' -c 'qa' >/dev/null 2>&1 &&
rm -rf /tmp/vim-plug/ && echo -e "成功" || echo -e "失败"
var dirname = process.cwd().split("/").reverse()[0];

module.exports = {
    scripts: {
        "dev": "npx webpack-dev-server",
        "clean": "([ -d dist ] && [ `ls dist | wc -l` -gt '0' ] && rm -r dist/*) || ([ -f dist ] && rm dist) || echo \"already cleaned\"",
        "build": "npx webpack",
        "init": "npm install --save-dev babel-loader @babel/core @babel/preset-env @babel/cli @babel/polyfill react-hot-loader webpack webpack-cli webpack-dev-server webpack-api-mocker html-webpack-plugin css-loader mini-css-extract-plugin less less-loader url-loader file-loader sass-loader node-sass",
    },
    name: dirname,
    version: "1.0.0",
};

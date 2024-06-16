import Bar from 'widget/bar/Bar';

const scss = `${App.configDir}/style/style.scss`;
const css = '/tmp/ags/style.css';
const sasscLog = Utils.exec(`sassc ${scss} ${css}`);
sasscLog && console.log(`sassc: ${sasscLog}`);

App.config({
    style: css,
    windows: [Bar(0)],
});

import Bar from 'widget/bar/Bar';

// const scss = `${App.configDir}/style/style.scss`;
// const css = '/tmp/ags/style.css';
// Utils.exec(`sassc ${scss} ${css}`);

App.config({
    // style: css,
    windows: [Bar(0)],
});

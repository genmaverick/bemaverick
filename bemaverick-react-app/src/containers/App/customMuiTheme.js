import getMuiTheme from 'material-ui/styles/getMuiTheme';

// import lightBaseTheme from 'material-ui/styles/baseThemes/lightBaseTheme';
// console.log('lighttheme', lightBaseTheme);

const customMuiTheme = getMuiTheme({
  fontFamily: 'Barlow, sans-serif',
  palette: {
    primary1Color: '#00B0AC',
    secondaryColor: '#f1495b',
  },
});

export default customMuiTheme;

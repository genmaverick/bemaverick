require.extensions['.css'] = () => {
  // https://github.com/roylee0704/react-flexbox-grid/issues/28#issuecomment-198758253
};
const withImages = require('next-images');

const nextConfig = {
  // eslint-disable-next-line no-unused-vars
  webpack(config, options) {
    config.node = { fs: 'empty', ...config.node }; // eslint-disable-line no-param-reassign
    config.module.rules.push({
      test: /\.css$/,
      loader: 'style-loader!css-loader',
      include: /flexboxgrid/,
    });
    config.module.rules.push({
      test: /\.css$/,
      loader: 'css-loader',
      include: /assets\/styles/,
    });

    return config;
  },
  // disable automatic routing
  useFileSystemPublicRoutes: false,
};

module.exports = withImages(nextConfig);

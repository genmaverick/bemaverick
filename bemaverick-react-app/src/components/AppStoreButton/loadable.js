import Loadable from 'react-loadable';
import Loading from '../Loading';
import Component from './index';

const LoadableComponent = Loadable({
  loader: () => import('./index'), // eslint-disable-line
  loading: Loading,
});

export default LoadableComponent;

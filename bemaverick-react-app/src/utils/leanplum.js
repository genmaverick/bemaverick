/* eslint-disable no-undef */
import Maverick from './maverick';

export default {
  async track(event, properties) {
    if (window.leanplum) {
      window.leanplum.track(event, properties);
    }
  },

  async setUserId() {
    if (window.leanplum) {
      Maverick.getCookieUser().then((response) => {
        if (response.status === 200
          && response.data
          && response.data.authenticated
        ) {
          const user = response.data;
          window.leanplum.setUserId(user.userId);
        }
      });
    }
  },

  async setUserAttributes() {
    if (window.leanplum) {
      Maverick.getCookieUser().then((response) => {
        if (response.status === 200
          && response.data
          && response.data.authenticated
        ) {
          const user = response.data;
          window.leanplum.setUserAttributes(
            user.userId,
            {
              username: user.username,
              firstName: user.firstName,
              lastName: user.lastName,
              email: user.emailAddress,
              title: user.userType,
              description: user.status,
            },
          );
        }
      });
    }
  },
};

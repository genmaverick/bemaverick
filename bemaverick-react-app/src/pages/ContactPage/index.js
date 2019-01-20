/* eslint import/first: 0 */
import React from 'react';
import TwoColumnPage from '../../layouts/EightFourPage';
import ContactForm from '../../components/forms/ContactForm';
import A from '../../components/common/A/index';
import P from '../../components/common/P/index';
import H3 from '../../components/common/H3/index';
import SocialIcons from '../../components/SocialIcons';

const styles = {
  formContainer: {
    width: '100%',
    maxWidth: '500px',
  },
};

export default () => (
  <div>
    <TwoColumnPage title="Get In Touch">
      {/* left column / children[0] */}
      <div>
        <P>Fill out the form below and we will get in touch ASAP.</P>
        <ContactForm widthObj={styles.formContainer} />
      </div>
      {/* right column / children[1] */}
      <div>
        <H3>Trouble with the App?</H3>
        <P>
          You can reach us at <A href="mailto:support@bemaverick.com">support@bemaverick.com</A> for all app support related needs.
        </P>
        <H3>Connect On Social</H3>
        <SocialIcons />
      </div>
    </TwoColumnPage>
  </div>
);

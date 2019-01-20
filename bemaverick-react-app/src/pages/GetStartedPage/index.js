import React from 'react';
import Radium from 'radium';
// import FadeIn from 'react-fade-in';
import FadeInUp from '../../components/Animation/FadeInUp';
import FadeIn from '../../components/Animation/FadeIn';
import BlankLayout from '../../layouts/BlankLayout';
import AppStoreButton from '../../components/AppStoreButton/loadable';
import Button from '../../components/Button';
import Border from '../../components/Border';
import Hashtag from '../../components/Hashtag';
import SectionSmall from '../../components/SectionSmall';
import logoStacked from '../../assets/images/logo-stacked.png';
import { Link } from '../../routes';
import A from "../../components/common/A";
import { textDark } from '../../assets/colors';

const styles = {
  textPrimary: {
    fontSize: 17,
    fontWeight: 500,
    textTransform: 'uppercase',
    letterSpacing: 1,
    lineHeight: '26pt'
  },
  buttonText: {
    letterSpacing: 2,
  },
};

const ChallengeDetailsPage = () => (
  <BlankLayout title="Get Started">
    <Border brushBackground>
      <FadeInUp>
        <SectionSmall textAlign="center" animation="fadeInDown">
          <A href="/"><img src={logoStacked} alt="Maverick Logo" /></A>
        </SectionSmall>
        <SectionSmall
          textAlign="center"
        >
          Use your voice to create and inspire. Be unstoppable and <Hashtag name="doyourthing" />.
        </SectionSmall>
        <SectionSmall
          textAlign="center"
          fontStyle={styles.textPrimary}
        >
          Download the mobile Maverick app for iOS, then you can do your thing from anywhere!
        </SectionSmall>
        <SectionSmall textAlign="center">
          <AppStoreButton />
        </SectionSmall>
        <SectionSmall textAlign="center">
          <Link route="/sign-up">
            <Button label="Sign up on the web app" labelStyle={styles.buttonText}/>
          </Link>
        </SectionSmall>
        <SectionSmall textAlign="center">
          Already have an account? <A href="sign-in">sign in</A>
        </SectionSmall>
      </FadeInUp>
    </Border>
  </BlankLayout>
);
ChallengeDetailsPage.getInitialProps = async (/* { query } */) => ({});

ChallengeDetailsPage.propTypes = {};

ChallengeDetailsPage.defaultProps = {};

export default Radium(ChallengeDetailsPage);

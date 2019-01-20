/* eslint import/first: 0 */
import React from "react";
import Radium from "radium";
import BlankLayout from "../../layouts/BlankLayout";
import Border from "../../components/Border";
import Hashtag from "../../components/Hashtag";
import SectionSmall from "../../components/SectionSmall";
import SignupForm from "../../components/forms/SignupMaverickStep2";
import logoStacked from "../../assets/images/logo-stacked.png";
import A from "../../components/common/A";
import { textDark } from '../../assets/colors';

const styles = {
};

const ChallengeDetailsPage = () => (
  <BlankLayout title="Sign Up">
    <Border style={styles.border}>
      <SectionSmall textAlign="center" animation="fadeInDown" >
        <A href="/"><img src={logoStacked} alt="Maverick Logo" /></A>
      </SectionSmall>
      <SectionSmall textAlign="center">
        Use your voice to create and inspire. Be unstoppable and{" "}
        <Hashtag name="doyourthing" />.
      </SectionSmall>
      <SectionSmall textAlign="center">
        <SignupForm />
      </SectionSmall>
      <SectionSmall textAlign="center">
        Already have an account? <A href="sign-in">sign in</A>
      </SectionSmall>
      <section style={styles.overlay}>&nbsp;</section>
    </Border>
  </BlankLayout>
);
ChallengeDetailsPage.getInitialProps = async (/* { query } */) => ({});

ChallengeDetailsPage.propTypes = {};

ChallengeDetailsPage.defaultProps = {};

export default Radium(ChallengeDetailsPage);

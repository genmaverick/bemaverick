/* eslint import/first: 0 */
import React from "react";
import BlankLayout from "../../layouts/BlankLayout";
import SigninForm from "../../components/forms/SigninForm";
import SectionSmall from "../../components/SectionSmall";
import Border from "../../components/Border";
import Hashtag from "../../components/Hashtag";
import A from "../../components/common/A";
import logoStacked from "../../assets/images/logo-stacked.png";

export default () => (
  <BlankLayout title="Sign Up">
    <Border>
      <SectionSmall textAlign="center" animation="fadeInDown">
        <A href="/"><img src={logoStacked} alt="Maverick Logo" /></A>
      </SectionSmall>
      <SectionSmall textAlign="center">
        Use your voice to create and inspire. Be unstoppable and{" "}
        <Hashtag name="doyourthing" />.
      </SectionSmall>
      <SectionSmall textAlign="center">
        <SigninForm />
      </SectionSmall>
      <SectionSmall textAlign="center">
        Don't have an account yet? <A href="sign-up">sign up</A>
      </SectionSmall>
    </Border>
  </BlankLayout>
);

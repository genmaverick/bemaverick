import React from 'react';
import config from '../utils/config';
import CustomHex from './CustomHex';

const teamInfo = [
  { img: 'brookechaffin', name: 'Brooke Chaffin', title: 'CEO and Co-founder' },
  { img: 'catherineconnors', name: 'Catherine Connors', title: 'CCO and Co-founder' },
  { img: 'normasantoyo', name: 'Norma Santoyo', title: 'Chief Operations Office and Head of Product' },
  { img: 'gokulkolandavel', name: 'Gokul Kolandavel', title: 'VP of Engineering' },
  { img: 'melissalawton', name: 'Melissa Lawton', title: 'General Counsel and Director of Partnerships' },
  { img: 'garretfritz', name: 'Garrett Fritz', title: 'Director of Mobile Engineering' },
  { img: 'michellematthews', name: 'Michelle Matthews', title: 'Lead UX/UI Designer' },
  { img: 'chrisfitkin', name: 'Chris Fitkin', title: 'Software Engineering Manager' },
  { img: 'selinazawacki', name: 'Selina Zawacki', title: 'Software Engineer' },
  { img: 'brittanyvanhorne', name: 'Brittany Van Horne', title: 'Social Media Editor and Producer' },
  { img: 'chrisgarvey', name: 'Chris Garvey', title: 'iOS Developer' },
  { img: 'danaedell', name: 'Dana Edell', title: 'Director of Community and Engagement' },
  { img: 'pablobalderas', name: 'Pablo Balderas', title: 'Video Editor' },
  { img: 'aliciarosa', name: 'Alicia Rosa', title: 'Visual Designer' },
];

const styles = {
  hexGrid: {
    marginLeft: '-20px',
    width: '100%',
  },
};

export default () => (
  <div style={styles.hexGrid}>
    <ul id="hexGrid">
      {
        teamInfo.map(({ img, name, title }) => (
          <CustomHex
            img={`${config.maverickSiteImages.url}/team/${img}.png`}
            name={name}
            title={title}
            key={img}
          />
        ))
      }
    </ul>
  </div>
);

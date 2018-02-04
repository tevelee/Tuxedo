/**
 * Copyright (c) 2017-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

const siteConfig = {
  title: 'Tuxedo',
  tagline: 'The Swift template engine',
  url: 'https://tevelee.github.io/Tuxedo/',
  baseUrl: '/Tuxedo/',
  projectName: 'Tuxedo',
  noIndex: false,
  headerLinks: [
    {doc: 'docs', label: 'Docs'},
    {doc: 'reference', label: 'API'},
    {blog: true, label: 'Blog'},
    {href: 'https://github.com/tevelee/Tuxedo', label: 'GitHub'},
    {search: true},
  ],
  author: {
    name: 'Laszlo Teveli',
    summary: 'Full-stack Software Engineer @Skyscanner\niOS Evangelist',
    avatar: 'https://pbs.twimg.com/profile_images/866651035317784576/kxJbTkD6_400x400.jpg',
    twitterLink: 'https://www.twitter.com/tevelee',
    facebookLink: 'https://www.facebook.com/tevelee',
    githubLink: 'https://www.github.com/tevelee',
    facebookID: 1512612418
  },
  headerIcon: 'img/tuxedo.svg',
  footerIcon: 'img/tuxedo.svg',
  favicon: 'img/favicon.png',
  colors: {
    primaryColor: '#1abc9c', // https://flatuicolors.com/palette/defo
    secondaryColor: '#e67e22',
  },
  copyright:
    'Copyright © ' +
    new Date().getFullYear() +
    ' Laszlo Teveli',
  organizationName: 'tevelee',
  projectName: 'Tuxedo',
  highlight: {
    theme: 'default',
  },
  scripts: ['https://buttons.github.io/buttons.js'],
  repoUrl: 'https://github.com/tevelee/Tuxedo',
  evalRepoUrl: 'https://github.com/tevelee/Eval',
  twitter: 'true',
  ogImage: 'img/tuxedo.png',
  // gaTrackingId
};

module.exports = siteConfig;

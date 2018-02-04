/**
 * Copyright (c) 2017-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

const React = require('react');

const CompLibrary = require('../../core/CompLibrary.js');
const MarkdownBlock = CompLibrary.MarkdownBlock; /* Used to read markdown */
const Container = CompLibrary.Container;
const GridBlock = CompLibrary.GridBlock;

const siteConfig = require(process.cwd() + '/siteConfig.js');

function imgUrl(img) {
  return siteConfig.baseUrl + 'img/' + img;
}

function docUrl(doc, language) {
  return siteConfig.baseUrl + 'docs/' + (language ? language + '/' : '') + doc;
}

function pageUrl(page, language) {
  return siteConfig.baseUrl + (language ? language + '/' : '') + page;
}

class Button extends React.Component {
  render() {
    return (
      <div className="pluginWrapper buttonWrapper">
        <a className="button" href={this.props.href} target={this.props.target}>
          {this.props.children}
        </a>
      </div>
    );
  }
}

Button.defaultProps = {
  target: '_self',
};

const SplashContainer = props => (
  <div className="homeContainer">
    <div className="homeSplashFade">
      <div className="wrapper homeWrapper">{props.children}</div>
    </div>
  </div>
);

const Logo = props => (
  <div className="projectLogo">
    <img src={props.img_src} />
  </div>
);

const ProjectTitle = props => (
  <h2 className="projectTitle">
    {siteConfig.title}
    <small>{siteConfig.tagline}</small>
  </h2>
);

const PromoSection = props => (
  <div className="section promoSection">
    <div className="promoRow">
      <div className="pluginRowBlock">{props.children}</div>
    </div>
  </div>
);

class HomeSplash extends React.Component {
  render() {
    let language = this.props.language || '';
    return (
      <SplashContainer>
        <div className="inner">
          <ProjectTitle />
          <PromoSection>
            <Button href="#try">Try It Out</Button>
            <Button href={docUrl('template-features.html', language)}>Features</Button>
            <Button href={docUrl('getting-started.html', language)}>Getting started</Button>
            <Button href={docUrl('how-does-it-work.html', language)}>How does it work</Button>
          </PromoSection>
        </div>
      </SplashContainer>
    );
  }
}

const Block = props => (
  <Container
    padding={['bottom', 'top']}
    id={props.id}
    background={props.background}>
    <GridBlock align="center" contents={props.children} layout={props.layout} />
  </Container>
);

const Features = props => (
  <Block layout="fourColumn">
    {[
      {
        title: 'Flexible',
        content: 'Tuxedo provides a flexible, extendible template engine',
        image: imgUrl('icons/network.svg'),
        imageAlign: 'top',
      },
      {
        title: 'Fast',
        content: 'Performs well even on large template files',
        image: imgUrl('icons/settings.svg'),
        imageAlign: 'top',
      },
      {
        title: 'Lightweight',
        content: 'The whole library is just a set of data types and functions butilt upon the <a href=' + siteConfig.evalRepoUrl + '>Eval</a> interpreter engine',
        image: imgUrl('icons/paper-plane-1.svg'),
        imageAlign: 'top',
      },
      {
        title: 'Comprehensive',
        content: 'Comes with a lot of built-in opeartors, functions, everything you might need',
        image: imgUrl('icons/calculator.svg'),
        imageAlign: 'top',
      },
    ]}
  </Block>
);

const FeatureCallout = props => (
  <div
    className="productShowcaseSection paddingBottom"
    style={{textAlign: 'center'}}>
    <h2>Feature Callout</h2>
    <MarkdownBlock>These are features of this project</MarkdownBlock>
  </div>
);

class LearnHow extends React.Component {
  render() {
    let language = this.props.language || '';
    return (
      <Container id="try" padding={["bottom", "top"]} background="light">
        <GridBlock contents={
          [
            {
              title: 'Learn How',
              content: `The [Getting Started](` + docUrl('getting-started.html', this.props.language || '') + `) documentation page is a great way to start.
There is a separate page, which details [template features](` + docUrl('template-features.html', this.props.language || '') + `) in depth as well.`,
              image: imgUrl('icons/sign-1.svg'),
              imageAlign: 'right',
            },
          ]}
          layout="twoColumn"
        />
      </Container>
    );
  }
}

class TryOut extends React.Component {
  render() {
    let language = this.props.language || '';
    return (
      <Container id="try" padding={["bottom", "top"]}>
        <GridBlock contents={
          [
            {
              title: 'Try it out',
              content: `There is a [playground included](` + siteConfig.repoUrl + `/tree/master/Tuxedo.playground) in the repository, which is a great way to try and experiment with the framework`,
              image: imgUrl('icons/laptop.svg'),
              imageAlign: 'left',
            },
          ]}
          layout="twoColumn"
        />
      </Container>
    );
  }
}

class Description extends React.Component {
  render() {
    let language = this.props.language || '';
    return (
      <Container padding={["bottom", "top"]} background="light">
        <GridBlock
          contents={
            [
              {
                content: `**Tuxedo** is a template language for Swift. 
It allows you to separate the UI and rendering layer of your application from the business logic. 
It dresses up your output with elegant template elements, control statements, and high level operators. Check out the [documentation](` + docUrl('docs.html', this.props.language || '') + `) for details.`,
                image: imgUrl('icons/newspaper.svg'),
                imageAlign: 'right',
                title: 'Overview',
              }
            ]}
          layout="twoColumn"
        />
      </Container>
    );
  }
}

const Story = props => (
  <Container padding={["bottom", "top"]} background="dark">
    <GridBlock
      contents={
        [
          {
            content: `The project was built upon my lightweight interpreter framework, [Eval](https://github.com/tevelee/Eval), and served as an example application of what is possible using this evaluator. 
Soon, the template language example turned out to be a really useful project on its own, so I extracted it to live as a separate library and be used by as many projects as possible. 
It is especially useful for **server-side Swift projects**, but there are a lot of other areas where template parsing fits well.`,
            image: imgUrl('icons/diamond.svg'),
            imageAlign: 'left',
            title: 'Story',
          }
        ]}
      layout="twoColumn"
    />
  </Container>
);

const Author = props => {
  return (
    <div className="productShowcaseSection">
      <h2>About the author</h2>
      <div className="logos">
        <a href={siteConfig.author.twitterLink}>
          <img src={siteConfig.author.avatar} title={siteConfig.author.name} />
        </a>
        <div style={{textAlign:'left'}}>
          <span>{siteConfig.author.name}</span>
          <p>{siteConfig.author.summary.split('\n').map((item, key) => <span key={key}>{item}<br/></span> )}</p>
        </div>
      </div>
    </div>
  );
};

class Index extends React.Component {
  render() {
    let language = this.props.language || '';

    return (
      <div>
        <HomeSplash language={language} />
        <div className="mainContainer">
          <Features />
          {/*<FeatureCallout />*/}
          <LearnHow />
          <TryOut />
          <Description />
          <Story />
          <Author language={language} />
        </div>
      </div>
    );
  }
}

module.exports = Index;

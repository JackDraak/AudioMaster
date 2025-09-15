# Contributing to AudioMaster

We love your input! We want to make contributing to AudioMaster as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code follows the project style guidelines
6. Issue that pull request!

## Testing Requirements

- All new features must include unit tests
- Performance tests must pass within specified thresholds
- Integration tests must cover device interaction scenarios
- Test coverage should not decrease

## Performance Benchmarks

Your changes must meet these performance criteria:
- Audio latency < 5ms
- CPU usage < 30% under normal load
- Feedback detection < 1ms
- Memory usage < 50MB

## Any contributions you make will be under the MIT Software License

In short, when you submit code changes, your submissions are understood to be under the same [MIT License](http://choosealicense.com/licenses/mit/) that covers the project. Feel free to contact the maintainers if that's a concern.

## Report bugs using GitHub's [issue tracker]

We use GitHub issues to track public bugs. Report a bug by [opening a new issue]()

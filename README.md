# kawa.ai
Kawa.ai is a platform for building applications using the power of large language models (LLMs). It provides a simple interface to create, manage, and download applications that leverage LLMs for various tasks.

## Features
Kawa.ai offers a comprehensive suite of features to streamline the development and deployment of LLM-powered applications:

- **Application Creation**: Easily create applications leveraging the capabilities of large language models.
- **Application Management**: Intuitive interface for managing your applications with ease.
- **Debugging Tools**: Built-in debugger compatible with VsCode for seamless debugging.
- **Local Deployment**: Download and run applications locally for testing and development.
- **Cross-Platform Compatibility**: Run Kawa.ai on any operating system that supports Golang, Python, and Dart&Flutter.
- **Scalability**: Optimized for performance and scalability, suitable for both small and large applications.


## Requirements
To install and run Kawa.ai, ensure you have the following dependencies installed on your machine:

- **Golang**: Required for backend services.
- **Python**: Required for certain functionalities and scripts.
- **Dart & Flutter**: Required for frontend development and editing. (Optional if not editing)


 ## Installation
To get started with Kawa.ai, follow these steps:
1. Clone the repository:
```bash
git clone https://github.com/fodedoumbouya/kawa.ai.git
```
2. Navigate to the project directory:
```bash
cd kawa.ai
```
3. Install the required dependencies:
```bash
make setup
```
4. Install dependencies and run the application:
```bash
make run-all
```



This command will check for the required dependencies and start all the services. If everything is set up correctly, you should see the following services running with their respective ports:
   | PROJECT         | URL                          | STATUS      |
   |-----------------|------------------------------|-------------|
   | vscode_preview  | http://127.0.0.1:8080        | ✓ Running   |
   | kawa            | http://127.0.0.1:8090        | ✓ Running   |
   | kawa_web        | http://0.0.0.0:8000         | ✓ Running   |

## Usage
Once Kawa.ai is installed, you can start creating applications using the web interface. Follow these steps to get started:

1. Open your web browser and navigate to:
   ```
   http://localhost:8000
   ```

2. From the web interface, you can:
   - Create new applications
   - Manage existing applications
   - Debug applications using the built-in VsCode debugger


## Aproach  
Kawa.ai is designed with a modular and scalable architecture that ensures each request to the LLM is self-contained. This means that each request is independent and does not rely on context or state from previous requests. This approach offers several advantages:

- **Modularity**: Each request can be handled independently, allowing for greater flexibility and modularity in application design.
- **Scalability**: Independent requests make it easier to scale applications horizontally, as there is no need to maintain state across requests.
- **Flexibility**: You can seamlessly switch between different LLM models within the same project, enabling diverse use cases and experimentation.
For more detailed information on our approach, please refer to our Approach Documentation.

## Contributing
We welcome contributions from the community! If you have ideas, suggestions, or improvements, please follow these steps:

1. **Open an Issue**: Before making changes, open an issue to discuss your proposal or report a bug.
2. **Fork the Repository**: Create a fork of the repository and make your changes in a new branch.
3. **Submit a Pull Request**: Once your changes are ready, submit a pull request with a clear description of your changes.

Please make sure to follow our [Contribution Guidelines](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md).

### Development Setup
For developers looking to contribute, here are some additional setup steps:

1. Ensure you have all the dependencies installed (Golang, Python, Dart & Flutter).
2. Run the tests to ensure everything is working correctly:
   ```bash
   make test
   ```

Thank you for contributing to Kawa.ai!

## Documentation
For detailed documentation, including API references, user guides, and tutorials, visit our [Documentation](#) page.

## License
Kawa.ai is licensed under the [MIT License](LICENSE). By contributing to this project, you agree to abide by its terms.

## Support
For support and questions, please join our [community forum](#).

## Roadmap
Check out our [roadmap](#) to see what features and improvements are planned for future releases.

## Acknowledgements
We would like to thank all our contributors and the open-source community for their support and contributions.
```

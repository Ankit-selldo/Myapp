# My App

A modern web application built with Ruby on Rails, featuring a blog system, product management, and PWA support.

## Features

- **Authentication System**
  - User registration and login
  - Role-based authorization (admin, editor, user)
  - Password reset functionality
  - Session management

- **Product Management**
  - CRUD operations for products
  - Sub-product support
  - Image attachments
  - Inventory tracking
  - Email notifications for back-in-stock items

- **Blog System**
  - Rich text editor
  - Featured images
  - Draft/Published/Archived states
  - SEO-friendly URLs
  - Social sharing

- **Progressive Web App (PWA)**
  - Offline support
  - Push notifications
  - Background sync
  - Installable on devices
  - Responsive design

## Requirements

- Ruby 3.4.3
- PostgreSQL
- Node.js
- Yarn

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/my_app.git
   cd my_app
   ```

2. Install dependencies:
   ```bash
   bundle install
   yarn install
   ```

3. Set up the database:
   ```bash
   rails db:create
   rails db:migrate
   ```

4. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

5. Start the server:
   ```bash
   bin/dev
   ```

## Environment Variables

Create a `.env` file with the following variables:

```
# Application
APP_NAME=My App
APP_SHORT_NAME=MyApp
APP_DESCRIPTION=A modern web application
APP_HOST=example.com

# Database
DATABASE_URL=postgres://username:password@localhost/my_app_development

# Email
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_DOMAIN=example.com
SMTP_USERNAME=your_username
SMTP_PASSWORD=your_password

# Storage
STORAGE_SERVICE=local # or amazon, google, microsoft
```

## Testing

Run the test suite:

```bash
rails test
```

Run system tests:

```bash
rails test:system
```

## Deployment

The application is configured for deployment using Kamal:

1. Set up your deployment configuration:
   ```bash
   cp config/deploy.example.yml config/deploy.yml
   # Edit deploy.yml with your server details
   ```

2. Set up your Docker credentials:
   ```bash
   kamal env push
   ```

3. Deploy the application:
   ```bash
   kamal setup
   kamal deploy
   ```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Security

For security issues, please email security@example.com instead of using the issue tracker.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- [Ruby on Rails](https://rubyonrails.org/)
- [Hotwire](https://hotwired.dev/)
- [Propshaft](https://github.com/rails/propshaft)
- [Kamal](https://kamal-deploy.org/)

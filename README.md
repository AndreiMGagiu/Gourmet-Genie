# Gourmet Genie

Gourmet Genie is a Rails application that helps users find recipes based on ingredients they have at home. It provides a powerful search functionality and ingredient matching system to suggest the best recipes for users.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Database Setup](#database-setup)
- [Importing Data](#importing-data)
- [Running the Application](#running-the-application)
- [API Endpoints](#api-endpoints)
- [Running Tests](#running-tests)

## Prerequisites

Before you begin, ensure you have the following installed:

- Ruby 3.3.0
- Rails 7.0.8 or higher
- PostgreSQL
- pg_trgm extension for PostgreSQL

## Installation

1. Clone the repository:
```bash 
 git clone git@github.com:AndreiMGagiu/Gourmet-Genie.git
 cd gourmet-genie
```

2. Install dependencies: `bundle install`

3. Set up environment variables:
Copy the `.env.example` file to `.env` and fill in the necessary environment variables:

## Database Setup
1. Create the database: `rails db:create`
2. Run migrations: `rails db:migrate`
3. Enable the `pg_trgm` extension:
```bash  
psql -d your_database_name -c 'CREATE EXTENSION IF NOT EXISTS pg_trgm;'
```

## Importing Data
To import recipe data, run the following rake task: `rails import:recipes`
This will import recipes from the `db/data/recipes.json` file.

## Running the Application
Start the Rails server: 
    `rails server`. The application will be available at `http://localhost:3000`.

## API Endpoints
```base
 GET /api/v1/recipes/search?ingredients=ingredient1,ingredient2: Search for recipes by ingredients
 GET /api/v1/recipes/:id/ingredients: Get ingredients, category, and ratings for a specific recipe
```

## Running Tests
To run the test suite: `rspec`

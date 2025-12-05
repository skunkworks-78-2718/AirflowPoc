{{
    config(
        materialized='view'
    )
}}

select * from {{ source('adventureworks', 'SalesOrderDetail') }}
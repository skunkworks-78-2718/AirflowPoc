{{
    config(
        materialized='view'
    )
}}

select * from {{ source('adventureworks', 'Customer') }}